# Exercise 9 - Rollout your application with Blue/Green deployment

## What is Blue/Green Deployment?

Kubernetes has a controller object called [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). 
A Deployment controller provides declarative updates for Pods and ReplicaSets.
Deployments are used to provide rolling updates, change the desired state of the pods, rollback to an earlier revision, etc.

However, there are many traditional workloads that won't work with Kubernetes way of rolling updates. 
If your workload needs to deploy a new version and cut over to it immediately then you may need to perform blue/green deployment instead.

Using Blue/Green deployment approach, you label the current production as “Blue”. Create an identical production environment called “Green” - Redirect the services to “Green”. 
If services are functional in “Green” - destroy “Blue”. If “Green” is bad - rollback to “Blue”.

## Create the Blue Application 

For this final exercise you will create a Percona (blue) workload, a service, job running a sql load generator. 
Then you will create another Percona (green) workload with the snapshot of the first Percona workload's persistent volume and switch the service at the same time.

First, create a Percona (blue) pod. Blue pod runs a Percona workload and writes to a persistent volume called `demo-vol1` created by the persistent volume claim `demo-vol1-claim`.  

1.  Make sure that you have cleared your environment. Delete all previosuly created pods, snapshots and PV/PVCs.

2.  Create the [blue-percona.yaml](blue-percona.yaml) file:

    ```
    nano blue-percona.yaml
    ```
    
3.  Paste the content and save.

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: blue
      labels:
        name: blue
        app: blue
    spec:
      containers:
      - resources:
          limits:
            cpu: 0.5
        name: blue
        image: percona
        args:
          - "--ignore-db-dir"
          - "lost+found"
        env:
          - name: MYSQL_ROOT_PASSWORD
            value: k8sDem0
        ports:
          - containerPort: 3306
            name: mysql
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: demo-vol1
      volumes:
      - name: demo-vol1
        persistentVolumeClaim:
          claimName: demo-vol1-claim
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
        
    metadata:
      name: demo-vol1-claim
    spec:
      storageClassName: openebs-percona
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5G
    
    ```

4.  Create the blue pod.

    ```
    $ kubectl create -f blue-percona.yaml
    pod "blue" created
    persistentvolumeclaim "demo-vol1-claim" created
    ```

## Create the service

1.  Create the service [percona-svc.yaml](percona-svc.yaml) file:

    ```
    nano percona-svc.yaml
    ```
    
2.  This service will forward all the mysql traffic to the blue pod. Paste the content and save.

    ```
    apiVersion: v1
    kind: Service
    metadata:
      name: percona
    spec:
      ports:
      - name: mysql
        port: 3306
        targetPort: mysql
      selector:
        app: blue
     ```
3.  Create the service.

    ```
    $ kubectl create -f percona-svc.yaml
    service "percona" created
    ```
    
4.  Record the service IP.

    ```
    $ kubectl get svc
    NAME                                                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
    alertmanager                                        NodePort    10.3.0.95    <none>        9093:31854/TCP      1d
    grafana                                             NodePort    10.3.0.139   <none>        3000:32515/TCP      1d
    kubernetes                                          ClusterIP   10.3.0.1     <none>        443/TCP             1d
    percona                                             ClusterIP   10.3.0.75    <none>        3306/TCP            1m
    prometheus-service                                  NodePort    10.3.0.8     <none>        80:32514/TCP        1d
    pvc-204a11af-744a-11e8-9f52-06731769042c-ctrl-svc   ClusterIP   10.3.0.247   <none>        3260/TCP,9501/TCP   2m
    ```
    
5.  In the example above IP is `10.3.0.75`.

## Create the load generator

1.  Create the load generator job [sql-loadgen.yaml](sql-loadgen.yaml) file:

    ```
    nano sql-loadgen.yaml
    ```
    
2.  This job will generate mysql load targeting the IP of the service that is forwarded to the Percona workload (currently blue). Paste the content, replace the target IP address (10.3.0.75) with your percona service IP and save.

    ```
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: sql-loadgen
    spec:
      template:
        metadata:
          name: sql-loadgen
        spec:
          restartPolicy: Never
          containers:
          - name: sql-loadgen
            image: openebs/tests-mysql-client
            command: ["/bin/bash"]
            args: ["-c", "timelimit -t 300 sh MySQLLoadGenerate.sh 10.3.0.75 > /dev/null 2>&1; exit 0"]
            tty: true
    ```
 
3.  Start the SQL load generator.

    ```
    kubectl create -f sql-loadgen.yaml
    ```
    
## (Optional) Monitor load on the blue workload

If you have previously configured Prometheus and Grafana to monitor OpenEBS volume you can use the Grafana Dashboard to monitor load generated by the sql-loadgenerator.

1.  Find out the pod name of your OpenEBS controller running the percona workload.

    ```
    $ kubectl get pod
    NAME                                                            READY     STATUS    RESTARTS   AGE
    alertmanager-79fc4b59db-82zmr                                   1/1       Running   0          1d
    blue                                                            1/1       Running   0          12m
    grafana-7688b94dc-lr578                                         1/1       Running   0          1d
    node-exporter-6gtgx                                             1/1       Running   0          1d
    node-exporter-btdp8                                             1/1       Running   0          1d
    node-exporter-k5v6t                                             1/1       Running   0          1d
    prometheus-deployment-78cd57c5d7-q4sbl                          1/1       Running   0          1d
    pvc-204a11af-744a-11e8-9f52-06731769042c-ctrl-c4944648d-kb2wq   2/2       Running   0          12m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-5jx6v   1/1       Running   0          12m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-nc8f4   1/1       Running   0          12m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-vldv6   1/1       Running   0          12m
    ```

2.  `pvc-204a11af-744a-11e8-9f52-06731769042c-ctrl-c4944648d-kb2wq` above is the controller. Now find out the IP of the controller:

    ```
    $ kubectl describe pod pvc-204a11af-744a-11e8-9f52-06731769042c-ctrl-c4944648d-kb2wq | grep IP
    IP:             10.2.2.53
    ```
    
3.  Open your Grafana Dashboard and choose the IP adddress of your controller from the "OpenEBS Volume" drop-down menu.

## Create the Green Application and switch the service

Once the `blue` application is running, you can take a snapshot, restore and use it for another workload. 

1.  We will switch the service to green, take a snapshot of blue's persistent volume and deploy the green workload in a new pod.

2.  Create the [snapshot.yaml](snapshot.yaml) file or use the one we have created in [Exercise-7](../exercise-7/README.md).

    ```
    nano snapshot.yaml
    ```
    
3.  Paste the content below and save.

    ```
    apiVersion: volumesnapshot.external-storage.k8s.io/v1
    kind: VolumeSnapshot
    metadata:
      name: snapshot-blue
      namespace: default
    spec:
      persistentVolumeClaimName: demo-vol1-claim
    ```

4.  Create the [green-percona.yaml](green-percona.yaml) file.

    ```
    nano green-percona.yaml
    ```
    
5.  Paste the content below and save.

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: green
      labels:
        name: green
        app: green
    spec:
      containers:
      - resources:
          limits:
            cpu: 0.5
        name: green
        image: percona
        args:
          - "--ignore-db-dir"
      -     "lost+found"
        env:
          - name: MYSQL_ROOT_PASSWORD
            value: k8sDem0
        ports:
          - containerPort: 3306
            name: mysql
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: demo-snap-vol1
      volumes:
      - name: demo-snap-vol1
        persistentVolumeClaim:
          claimName: demo-snap-vol-claim
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: demo-snap-vol-claim
      annotations:    
        snapshot.alpha.kubernetes.io/snapshot: snapshot-blue
    spec:
      storageClassName: snapshot-promoter
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5G
    ```  
    
6.  Edit the service replace `blue` with `green` and save changes. 
    
    ```
    kubectl edit svc percona
    ```   
    
7.  Create snapshot and deploy the green application:    

    ```
    $ kubectl create -f snapshot.yaml
    volumesnapshot.volumesnapshot.external-storage.k8s.io "snapshot-blue" created
    ```
    
    ```
    $ kubectl create -f green-percona.yaml
    pod "green" created
    persistentvolumeclaim "demo-snap-vol-claim" created
    ```

## Verify I/O 

1.  Find out the pod name of your OpenEBS controller running the green workload. Most recently created OpenEBS controller will be the one running the replicas of green workload.

    ```
    $ kubectl get pods
    NAME                                                             READY     STATUS    RESTARTS   AGE
    alertmanager-79fc4b59db-82zmr                                    1/1       Running   0          1d
    blue                                                             1/1       Running   0          43m
    grafana-7688b94dc-lr578                                          1/1       Running   0          1d
    green                                                            1/1       Running   0          15m
    node-exporter-6gtgx                                              1/1       Running   0          1d
    node-exporter-btdp8                                              1/1       Running   0          1d
    node-exporter-k5v6t                                              1/1       Running   0          1d
    prometheus-deployment-78cd57c5d7-q4sbl                           1/1       Running   0          1d
    pvc-0da4ab36-744e-11e8-9f52-06731769042c-ctrl-7c7cd7c8d7-dh6tn   2/2       Running   0          15m
    pvc-0da4ab36-744e-11e8-9f52-06731769042c-rep-5d9cc7c75b-bxnvv    1/1       Running   0          15m
    pvc-0da4ab36-744e-11e8-9f52-06731769042c-rep-5d9cc7c75b-w4z2j    1/1       Running   1          15m
    pvc-0da4ab36-744e-11e8-9f52-06731769042c-rep-5d9cc7c75b-xhlms    1/1       Running   0          15m
    pvc-204a11af-744a-11e8-9f52-06731769042c-ctrl-c4944648d-kb2wq    2/2       Running   0          43m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-5jx6v    1/1       Running   0          43m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-nc8f4    1/1       Running   0          43m
    pvc-204a11af-744a-11e8-9f52-06731769042c-rep-6d97f4747c-vldv6    1/1       Running   0          43m
    sql-loadgen-7hpc2                                                1/1       Running   0          7s
    ```
2.  `pvc-0da4ab36-744e-11e8-9f52-06731769042c-ctrl-7c7cd7c8d7-dh6tn` above is the new controller. Now find out the IP of the controller:

    ```
    $ kubectl describe pod pvc-0da4ab36-744e-11e8-9f52-06731769042c-ctrl-7c7cd7c8d7-dh6tn | grep IP
    IP:             10.2.2.56
    ```
    
3.  Open your Grafana Dashboard and choose the IP adddress of your controller from the "OpenEBS Volume" drop-down menu.

4.  You will notice that I/O is currently coming to the new controller used by the green workload.
