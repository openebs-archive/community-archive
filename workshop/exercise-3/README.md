# Exercise 3 - Deploying stateful workload on OpenEBS

In this exercise, we will learn how to deploy a stateful workload on OpenEBS persistent volume.

## Quick Review of a Storage Class 

Storage Classes are the foundation of dynamic provisioning in Kubernetes, allowing cluster administrators to define abstractions for the underlying storage platform.
Users simply refer to a StorageClass by name in the PersistentVolumeClaim (PVC) using the “storageClassName” parameter.

1.  Let's take a look at one.

    ```
    $ kubectl describe sc openebs-mongodb
    Name:            openebs-mongodb
    IsDefaultClass:  No
    Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"openebs-mongodb","namespace":""},"parameters":{"openebs.io/capacity":"5G","openebs.io/fstype":"xfs","openebs.io/jiva-replica-count":"3","openebs.io/storage-pool":"default","openebs.io/volume-monitor":"true"},"provisioner":"openebs.io/provisioner-iscsi"}
        
    Provisioner:           openebs.io/provisioner-iscsi
    Parameters:            openebs.io/capacity=5G,openebs.io/fstype=xfs,openebs.io/jiva-replica-count=3,openebs.io/storage-pool=default,openebs.io/volume-monitor=true
    AllowVolumeExpansion:  <unset>
    MountOptions:          <none>
    ReclaimPolicy:         Delete
    VolumeBindingMode:     Immediate
    Events:                <none>
    ```
    
## Optional: Setting up a default StorageClass

If you set one of the OpenEBS StorageClasses as default StorageClass, then all you need to do is create a PersistentVolumeClaim (PVC) and OpenEBS will take care of the rest – there is no need to specify the storageClassName. You can use Kubernetes annotations to attach arbitrary non-identifying metadata to objects. Clients such as tools and libraries can retrieve this metadata. The OpenEBS operator makes use of these annotations to determine, in this case, what storage class is the default. 

1.  Here is how you can set a default Storage Class:

    ```
    kubectl patch storageclass openebs-standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    ```

2.  Confirm default Storage Class is set:

    ```
    $ kubectl get sc
    NAME                         PROVISIONER                                                AGE
    openebs-cassandra            openebs.io/provisioner-iscsi                               1h
    openebs-es-data-sc           openebs.io/provisioner-iscsi                               1h
    openebs-jupyter              openebs.io/provisioner-iscsi                               1h
    openebs-kafka                openebs.io/provisioner-iscsi                               1h 
    openebs-mongodb              openebs.io/provisioner-iscsi                               1h
    openebs-percona              openebs.io/provisioner-iscsi                               1h
    openebs-redis                openebs.io/provisioner-iscsi                               1h
    openebs-standalone           openebs.io/provisioner-iscsi                               1h
    openebs-standard (default)   openebs.io/provisioner-iscsi                               1h
    openebs-zk                   openebs.io/provisioner-iscsi                               1h
    snapshot-promoter            volumesnapshot.external-storage.k8s.io/snapshot-promoter   1h
    ``` 

## Deploy PostgreSQL

1.  View an example deployment:

    ```
    cd ~/openebs/k8s/demo/crunchy-postgres/
    nano set.json
    ```

2.  Here is how the file should look like, pay attention to the storageClassName parameter:

    ```
    $ cat set.json
    {
      "apiVersion": "apps/v1beta1",
      "kind": "StatefulSet",
      "metadata": {
        "name": "pgset"
      },
      "spec": {
        "serviceName": "pgset",
        "replicas": 2,
        "template": {
          "metadata": {
            "labels": {
              "app": "pgset"
            }
          },
          "spec": {
            "securityContext":
              {
                "fsGroup": 26
              },
            "containers": [
              {
                "name": "pgset",
                "image": "crunchydata/crunchy-postgres:centos7-10.4-1.8.3",
                "ports": [
                  {
                    "containerPort": 5432,
                    "name": "postgres"
                  }
                ],
                "env": [{
                    "name": "PG_PRIMARY_USER",
                    "value": "primaryuser"
                }, {
                    "name": "PGHOST",
                    "value": "/tmp"
                }, {
                    "name": "PG_MODE",
                    "value": "set"
                }, {
                    "name": "PG_PRIMARY_PASSWORD",
                    "value": "password"
                }, {
                    "name": "PG_USER",
                    "value": "testuser"
                }, {
                    "name": "PG_PASSWORD",
                    "value": "password"
                }, {
                    "name": "PG_DATABASE",
                    "value": "userdb"
                }, {
                    "name": "PG_ROOT_PASSWORD",
                    "value": "password"
                }, {
                    "name": "PG_PRIMARY_PORT",
                    "value": "5432"
                }, {
                    "name": "PG_PRIMARY_HOST",
                    "value": "pgset-primary"
                }],
                "volumeMounts": [
                  {
                    "name": "pgdata",
                    "mountPath": "/pgdata",
                    "readOnly": false
                  }
                ]
              }
            ]
          }
        },
        "volumeClaimTemplates": [
          {
            "metadata": {
              "name": "pgdata"
            },
            "spec": {
              "accessModes": [
                "ReadWriteOnce"
              ],
              "storageClassName": "openebs-standard",
              "resources": {
                "requests": {
                  "storage": "400M"
                }
              }
            }
          }
        ]
      }
    }
    ```

    This example will create service and a statefulset that will deploy a primary and replica Postgres pods, both protected by OpenEBS PVs, created by PVCs that are requested by the `openebs-standard` storage class.  

3.  Deploy our example PostgreSQL workload.   
    
    ```
    ./run/sh
    ```

4.  Validate your stateful workload by checking the services, PODs and PVC/PVs created.

    ```
    $ kubectl get services
    NAME                                                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
    kubernetes                                          ClusterIP   10.3.0.1     <none>        443/TCP             2h
    maya-apiserver-service                              ClusterIP   10.3.0.131   <none>        5656/TCP            1h
    pgset                                               ClusterIP   None         <none>        5432/TCP            1m
    pgset-primary                                       ClusterIP   10.3.0.194   <none>        5432/TCP            1m
    pgset-replica                                       ClusterIP   10.3.0.146   <none>        5432/TCP            1m
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8-ctrl-svc   ClusterIP   10.3.0.55    <none>        3260/TCP,9501/TCP   1m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8-ctrl-svc   ClusterIP   10.3.0.30    <none>        3260/TCP,9501/TCP   22s
    ```
   
    ```
    $ kubectl get pods
    NAME                                                             READY     STATUS    RESTARTS   AGE
    maya-apiserver-6cfd67f8-2nlhd                                    1/1       Running   0          1h
    openebs-provisioner-6797d44769-dxk82                             1/1       Running   0          1h
    openebs-snapshot-controller-565d8f576d-pj5f9                     2/2       Running   0          1h
    pgset-0                                                          1/1       Running   0          2m
    pgset-1                                                          1/1       Running   0          1m
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8-ctrl-6478f9bc5c-mjjv7   2/2       Running   0          2m
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8-rep-7895ddc9cd-8dpr8    1/1       Running   0          2m
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8-rep-7895ddc9cd-dxg29    1/1       Running   0          2m
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8-rep-7895ddc9cd-m9t9q    1/1       Running   0          2m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8-ctrl-664dfd879f-frztl   2/2       Running   0          1m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8-rep-fc44bf78c-7jf8m     1/1       Running   0          1m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8-rep-fc44bf78c-7q75k     1/1       Running   0          1m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8-rep-fc44bf78c-vxssz     1/1       Running   0          1m
    ```
   
    Confirm that both pgset-0 and pgest-1 are running and OpenEBS controller with 3 replicas each are created.
   
5.  Get the list of PVCs and PVs created for your application.
    
    ```
    $ kubectl get pvc
    NAME             STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
    pgdata-pgset-0   Bound     pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8   400M       RWO            openebs-standard   5m
    pgdata-pgset-1   Bound     pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8   400M       RWO            openebs-standard   4m
    ```
    
    ```
    $ kubectl get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                    STORAGECLASS       REASON    AGE
    pvc-3f188c65-6f60-11e8-9e48-0698b18c8dc8   400M       RWO            Delete           Bound     default/pgdata-pgset-0   openebs-standard             6m
    pvc-658c765c-6f60-11e8-9e48-0698b18c8dc8   400M       RWO            Delete           Bound     default/pgdata-pgset-1   openebs-standard             4m
    ```
    
Now you have your stateful workload up and running.
   
### [Continue to Exercise 4 - Storage Classes & Storage Policies](../exercise-4)
