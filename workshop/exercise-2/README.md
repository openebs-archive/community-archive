# Exercise 2 - Installing OpenEBS

In this exercise, we will learn how to deploy and validate OpenEBS on a functional Kubernetes cluster.

## Setting up OpenEBS and new Storage Classes

1.  Download the latest OpenEBS Operator files using the following commands:

    ```
    git clone https://github.com/openebs/openebs.git
    cd openebs/k8s
    ```

2.  By default, OpenEBS launches OpenEBS Volumes with three replicas. To set one replica, as is the case with a single-node Kubernetes cluster, in the openebs-operator.yaml file, specify the environment variable `DEFAULT_REPLICA_COUNT=1` or edit the operator file directly.

3.  Optional: By default, OpenEBS uses `/var/openebs` directory on every available node to create replica files. If you like to change the default or create a new StoragePool resource, you can edit `openebs-config.yaml` file and set a custom path. 

4.  Apply the configuration changes:
    
    ```
    kubectl apply -f openebs-operator.yaml
    kubectl apply -f openebs-config.yaml
    ```

5.  Add the OpenEBS storage classes that can then be used by developers and applications:

    ```
    kubectl apply -f openebs-storageclasses.yaml
    ```

6.  Validate OpenEBS deployment

    ```
    $ kubectl get pods --namespace openebs
    NAME                                           READY     STATUS    RESTARTS   AGE
    maya-apiserver-6cfd67f8-2nlhd                  1/1       Running   0          21s
    openebs-provisioner-6797d44769-dxk82           1/1       Running   0          21s
    openebs-snapshot-controller-565d8f576d-pj5f9   2/2       Running   0          21s
    ```

    Confirm that all the three OpenEBS pods (maya-apiserver, openebs-provisioner and openebs-snapshot-controller) are in `Running` state.

    To use OpenEBS as persistent storage for your stateful workloads, we will need to set the `storageclass` in the Persistent Volume Claim (PVC) of your application to one of the OpenEBS storage class, therefore you need to know the `storageclass` name.

7.  Get the list of storage classes using the following command. Choose a `storageclass` that best suits your application.
    
    ```
    $ kubectl get sc
    NAME                 PROVISIONER                                                AGE
    openebs-cassandra    openebs.io/provisioner-iscsi                               2m
    openebs-es-data-sc   openebs.io/provisioner-iscsi                               2m
    openebs-jupyter      openebs.io/provisioner-iscsi                               2m
    openebs-kafka        openebs.io/provisioner-iscsi                               2m
    openebs-mongodb      openebs.io/provisioner-iscsi                               2m
    openebs-percona      openebs.io/provisioner-iscsi                               2m
    openebs-redis        openebs.io/provisioner-iscsi                               2m
    openebs-standalone   openebs.io/provisioner-iscsi                               2m
    openebs-standard     openebs.io/provisioner-iscsi                               2m
    openebs-zk           openebs.io/provisioner-iscsi                               2m
    snapshot-promoter    volumesnapshot.external-storage.k8s.io/snapshot-promoter   2m
    ```

8.  Optional: To create your own storage class, create a YAML file (example: [mystorageclass.yaml](mystorageclass.yaml)) similar to below, customize parameters, save and apply using `kubectl apply -f mystorageclass.yaml' command:
    
    ```
    # Define a storage classes supported by OpenEBS

    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
       name: openebs-mystorageclass
    provisioner: openebs.io/provisioner-iscsi
    parameters:
      openebs.io/storage-pool: "default"
      openebs.io/jiva-replica-count: "4"
      openebs.io/volume-monitor: "true"
      openebs.io/capacity: 5G
      ```

9.  To see the storage class definition such as storage pool, replica count and capacity run the comment below:
    
    ```
    $ kubectl describe sc openebs-standard
    Name:            openebs-standard
    IsDefaultClass:  No
    Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"openebs-standard","namespace":""},"parameters":{"openebs.io/capacity":"5G","openebs.io/jiva-replica-count":"3","openebs.io/storage-pool":"default","openebs.io/volume-monitor":"true"},"provisioner":"openebs.io/provisioner-iscsi"}
    
    Provisioner:           openebs.io/provisioner-iscsi
    Parameters:            openebs.io/capacity=5G,openebs.io/jiva-replica-count=3,openebs.io/storage-pool=default,openebs.io/volume-monitor=true
    AllowVolumeExpansion:  <unset>
    MountOptions:          <none>
    ReclaimPolicy:         Delete
    VolumeBindingMode:     Immediate
    Events:                <none>
    ```
Now you have your OpenEBS deployment up and running.
   
### [Continue to Exercise 3 - Deploying stateful workload on OpenEBS](../exercise-3)
