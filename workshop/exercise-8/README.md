# Exercise 8 - Cloning and Restoring a Snapshot

## Cloning and Restoring a Snapshot 

After creating a snapshot, you can restore it to a new Persitent Volume Claim. To do this you must create a special `StorageClass` implemented by snapshot-provisioner. 
We will then create a `PersistentVolumeClaim` referencing this `StorageClass` for dynamically provisioning new `PersistentVolume`. 
An annotation on the `PersistentVolumeClaim` will inform `snapshot-provisioner` about where to find the information it needs to deal with the OpenEBS API Server to restore the snapshot. 

A `StorageClass` can be defined as in the following example. Here, the `provisioner` field defines which provisioner should be used and what parameters should be passed to that provisioner when dynamic provisioning is invoked.

Such a `StorageClass` is necessary for restoring a Persistent Volume from an already created Volume Snapshot and Volume Snapshot Data.

## Create a Storage Class to restore from Snapshot

1.  Create the storageclass YAML file:

    ```
    nano openebs-restore-storageclass.yaml
    ```
    
2.  Paste the content and save.

    ```
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: snapshot-promoter
    provisioner: volumesnapshot.external-storage.k8s.io/snapshot-promoter
    ```
    
    `annotations:` snapshot.alpha.kubernetes.io/snapshot: the name of the Volume Snapshot that will be restored.
    `storageClassName:` Storage Class created by the admin for restoring Volume Snapshots.

3.   Once the openebs-restore-storageclass is created, you have to deploy the YAML by using the following command.

     ```
     kubectl apply -f openebs-restore-storageclass.yaml
     ```

## Restore from Snapshot

You can now create a `PersistentVolumeClaim` that will use the `StorageClass` to dynamically provision a `PersistentVolume` that contains the information of your snapshot. Create a YAML file that will delpoy a `PersistentVolumeClaim` using the following details.  

1.  Create the Persistent Volume Claim YAML file:

    ```
    nano restore-pvc.yaml
    ```
    
2.  Paste the content and save.

    ```
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: demo-snap-vol-claim
      annotations:
        snapshot.alpha.kubernetes.io/snapshot: snapshot-blue
    spec:
      storageClassName: snapshot-promoter
      accessModes: ReadWriteOnce
      resources:
        requests:
          storage: 1G
    ```

3.  Once the `restore-pvc.yaml` is created,  you have to deploy the YAML by using the following command.

    ```
    kubectl apply -f restore-pvc.yaml
    ```

4.  Finally mount the `demo-snap-vol-claim` PersistentVolumeClaim into a green pod to see that the snapshot was restored. While deploying the green pod, you have to edit the deplyment YAML and mention the restore `PersistentVolumeClaim` name, `volume` name, and `mountPath` accordingly. An example for your reference is given below. 

2.  Paste the content and save.

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: green
    spec:
      restartPolicy: Never
      containers:
      - name: green
        image: busybox
        command:
        - "/bin/sh"
        - "-c"
        - "while true; do date >> /tmp/pod-out.txt; sleep 1; done"
        volumeMounts:
        - name: demo-snap-vol1
          mountPath: /tmp
      volumes:
        - name: demo-snap-vol1
          persistentVolumeClaim:
            claimName: demo-snap-vol-claim
    ---

3.  Once `green.yaml` is created, you can deploy the YAML by using the following command:

    ```
    kubectl apply -f green.yaml
    ```
    
4.  List pods and verify green pod is running. 

    ```
    $ kubectl get pods
    NAME                                                             READY     STATUS    RESTARTS   AGE
    alertmanager-79fc4b59db-82zmr                                    1/1       Running   0          21h
    blue                                                             1/1       Running   0          20h
    grafana-7688b94dc-lr578                                          1/1       Running   0          21h
    green                                                            1/1       Running   0          2m
    node-exporter-6gtgx                                              1/1       Running   0          21h
    node-exporter-btdp8                                              1/1       Running   0          21h
    node-exporter-k5v6t                                              1/1       Running   0          21h
    prometheus-deployment-78cd57c5d7-q4sbl                           1/1       Running   0          21h
    pvc-b6cd585c-73e8-11e8-9f52-06731769042c-ctrl-546ddc8969-f9s97   2/2       Running   0          6m
    pvc-b6cd585c-73e8-11e8-9f52-06731769042c-rep-699f4948c5-bmgdn    1/1       Running   0          6m
    pvc-b6cd585c-73e8-11e8-9f52-06731769042c-rep-699f4948c5-djmv6    1/1       Running   1          6m
    pvc-b6cd585c-73e8-11e8-9f52-06731769042c-rep-699f4948c5-thl82    1/1       Running   0          6m
    pvc-d2e08c54-733e-11e8-9f52-06731769042c-ctrl-949dd445f-czm2b    2/2       Running   0          20h
    pvc-d2e08c54-733e-11e8-9f52-06731769042c-rep-878485f7-qnvd9      1/1       Running   0          20h
    pvc-d2e08c54-733e-11e8-9f52-06731769042c-rep-878485f7-s5nsn      1/1       Running   0          20h
    pvc-d2e08c54-733e-11e8-9f52-06731769042c-rep-878485f7-xmdpc      1/1       Running   0          20h
    ```
    
5.  List persistent volumes and verify that `demo-snap-vol-claim` exist claimed by the `snapshot-promoter`.

    ```
    $ kubectl get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                         STORAGECLASS        REASON    AGE
    pvc-2dcb6cfd-733a-11e8-9f52-06731769042c   400M       RWO            Delete           Bound     default/pgdata-pgset-1        openebs-standard              20h
    pvc-b6cd585c-73e8-11e8-9f52-06731769042c   1G         RWO            Delete           Bound     default/demo-snap-vol-claim   snapshot-promoter             5m
    pvc-d2e08c54-733e-11e8-9f52-06731769042c   1G         RWO            Delete           Bound     default/demo-vol1-claim       openebs-standard              20h
    ```
    
6.  Once the green pod is in running state, you can check the integrity of files which were created earlier before taking the snapshot.

    ```
    $ kubectl exec -it green cat /tmp/pod-out.txt
    ...
    Mon Jun 18 21:31:19 UTC 2018
    Mon Jun 18 21:31:20 UTC 2018
    Mon Jun 18 21:31:21 UTC 2018
    ...
    ```

### [Continue to Exercise 9 - Rollout your application with Blue/Green deployment](../exercise-9)
