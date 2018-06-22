# Exercise 7 - Taking a snapshot of a Persistent Volume

## What is a Snapshot?

A storage snapshot is a set of reference markers for data at a particular point in time. A snapshot acts like a detailed table of contents, providing you with accessible copies of data that you can roll back to.

The possible operations of this feature is creating, restoring, and deleting a snapshot.

OpenEBS operator will deploy a `snapshot-controller` and a `snapshot-provisioner` container inside a single pod called `snapshot-controller`.

`Snapshot-controller` will create a CRD for `VolumeSnapshot` and `VolumeSnapshotData` custom resources when it starts and will also watch for `VolumeSnapshotresources` and take snapshots of the volumes based on the referred snapshot plugin. 

Snapshot-provisioner will be used to restore a snapshot as a new persistent volume via dynamic provisioning.

With OpenEBS 0.6 release [openebs-operator.yaml](https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-operator.yaml) deploys both snapshot-controller and snapshot-provisioner. 

1.  Once snapshot-controller is running, run the command below to see the created CustomResourceDefinitions (CRD):

    ```
    $ kubectl get crd
    kubectl get crd
    NAME                                                         AGE
    storagepoolclaims.openebs.io                                 4h
    storagepools.openebs.io                                      4h
    volumepolicies.openebs.io                                    4h
    volumesnapshotdatas.volumesnapshot.external-storage.k8s.io   4h
    volumesnapshots.volumesnapshot.external-storage.k8s.io       4h
    ```

## Creating a stateful workload to take a snapshot

Before creating a snapshot, you must have a PersistentVolumeClaim for which you need to take a snapshot.

Let's deploy a basic application that writes to persistent disk called [blue.yaml](blue.yaml). Once you deploy the blue application, it's PVC will be created by the name specified in the application deployment yaml, for example `demo-vol1-claim`.  

1.  Create the application YAML file:

    ```
    nano blue.yaml
    ```
    
2.  Paste the below content and save. This pod write time into a file called pod-out.txt stored on the persistent volume it creates and mounted to the `/tmp` folder.

    ```
    apiVersion: v1
    kind: Pod
    metadata:
      name: blue
    spec:
      restartPolicy: Never
      containers:
      - name: blue
        image: busybox
        command:
        - "/bin/sh"
        - "-c"
        - "while true; do date >> /tmp/pod-out.txt; sleep 1; done"
        volumeMounts:
        - name: blue-volume
          mountPath: /tmp
      volumes:
      - name: blue-volume
        persistentVolumeClaim:
          claimName: demo-vol1-claim
    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: demo-vol1-claim
    spec:
      storageClassName: openebs-standard
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1G
    ```

3.  Create the deployment.

    ```
    $ kubectl create -f blue.yaml
    pod "blue" created
    persistentvolumeclaim "demo-vol1-claim" created
    ```

## Taking a snapshot of a Persistent Volume

Once the `blue` application is running, you can take a snapshot. After creating the `VolumeSnapshot` resource, `snapshot-controller` will attempt to create the actual snapshot by interacting with the snapshot APIs. If successful, the `VolumeSnapshot` resource is bound to a corresponding `VolumeSnapshotData` resource. 

To create a snapshot you must reference the `PersistentVolumeClaim` name in the snapshot specification that references the data you want to snapshot. 

1.  Validate the PV status and name of the claim.

    ```
    $ kubectl get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                     STORAGECLASS       REASON    AGE
    pvc-d2e08c54-733e-11e8-9f52-06731769042c   1G         RWO            Delete           Bound     default/demo-vol1-claim   openebs-standard             2m
    ```
    
2.  Create the snapshot YAML file. Example used here [snapshot.yaml](snapshot.yaml)

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

4.  Create snapshot:
    
    ```
    $ kubectl create -f snapshot.yaml
    volumesnapshot.volumesnapshot.external-storage.k8s.io "snapshot-blue" created
    ```

5.  List snapshots:

    ```
    $ kubectl get volumesnapshot 
    NAME            AGE 
    snapshot-blue   18s
    ```

6.  The output above shows that your snapshot was created successfully. You can also check the snapshot-controller’s logs to verify this by using the following commands. 

    ```
    $ kubectl create -f snapshot.yaml
    volumesnapshot.volumesnapshot.external-storage.k8s.io "snapshot-blue" created
    ubuntu@ip-172-23-1-130:~$ kubectl get volumesnapshot
    NAME            AGE
    snapshot-blue   11m
    ubuntu@ip-172-23-1-130:~$ kubectl get volumesnapshot -o yaml
    apiVersion: v1
    items:
    - apiVersion: volumesnapshot.external-storage.k8s.io/v1
      kind: VolumeSnapshot
      metadata:
        clusterName: ""
        creationTimestamp: 2018-06-18T21:42:50Z
        generation: 1
        labels:
          SnapshotMetadata-PVName: pvc-d2e08c54-733e-11e8-9f52-06731769042c
          SnapshotMetadata-Timestamp: "1529358170229916897"
        name: snapshot-blue
        namespace: default
        resourceVersion: "26424"
        selfLink: /apis/volumesnapshot.external-storage.k8s.io/v1/namespaces/default/volumesnapshots/snapshot-blue
        uid: 8c2f17bc-7340-11e8-9f52-06731769042c
      spec:
        persistentVolumeClaimName: demo-vol1-claim
        snapshotDataName: k8s-volume-snapshot-8c3bf11f-7340-11e8-8b06-0a580a020205
      status:
        conditions:
        - lastTransitionTime: 2018-06-18T21:42:50Z
          message: Snapshot created successfully
          reason: ""
          status: "True"
          type: Ready
        creationTimestamp: null
    kind: List
    metadata:
      resourceVersion: ""
      selfLink: ""
    ```

Once you have taken a snapshot, you can create a clone from the snapshot and restore your data.

## Deleting a Snapshot

You can delete a snapshot that you have created which will also delete the corresponding Volume Snapshot Data resource from Kubernetes.

1.  The following command will delete the snapshot you have created.
    
    ```
    $ kubectl delete -f snapshot.yaml
    ```
   
### [Continue to Exercise 8 - Cloning and Restoring a Snapshot](../exercise-8)
