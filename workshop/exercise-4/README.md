# Exercise 4 - Storage Policies

In this exercise, we will learn how to modify and use Storage Classes and Storage Policies.

## Quick Review of a Storage Class and Policies

A `StorageClass` provides a way for administrators to describe the “classes” of storage they offer. Different classes might map to quality-of-service levels, or to backup/snapshot policies, or to arbitrary policies determined by the DevOps architects. Kubernetes itself is unopinionated about what classes represent. 

You can define policies based on the type of application at the `StorageClass` (a Kubernetes Kind) level. This exercise explains when to add a storage policy to your OpenEBS cluster and how to use the same.

A storage policy states the desired behavior of an OpenEBS volume. Storage policies can be created, updated, and deleted in a running OpenEBS cluster through corresponding operations on `StorageClass`. Cluster administrators can update storage policies independent of the cluster. Once a storage policy is installed, users can create and access it’s objects with `kubectl` commands on `StorageClass`.

Storage policies are meant to be created per team, workload, storage controller, and so on that fits your requirement. Since OpenEBS storage controllers (i.e. jiva or cStor) run from within a container, a custom storage policy can be created and set against a particular storage controller instance that meets the demands of the application (which consumes the storage exposed from the storage controller instance). You can now define policies based on the type of application at the `StorageClass` level. Following are some of the properties that can be customized at the default level in the [openebs-storageclasses.yaml](openebs-storageclasses.yaml) file.

## Types of Storage Policies
OpenEBS supports several types of Storage Policies:

- openebs.io/jiva-replica-count
- openebs.io/jiva-replica-image
- openebs.io/jiva-controller-image
- openebs.io/storage-pool
- openebs.io/capacity
- openebs.io/fstype
- openebs.io/volume-monitor

### Replica Count Policy

You can specify the jiva replica count using the `openebs.io/jiva-replica-count` property. In the following example, the jiva-replica-count is specified as 1. Hence, a single replica is created.

1.  Create an empty [openebs-mystrorageclass1.yaml](openebs-mystorageclass1.yaml) YAML file and edit:

    ```
    nano openebs-mystorageclass1.yaml
    ```

2.  Add the following content:
    
    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
        name: openebs-mystorageclass
    provisioner: openebs.io/provisioner-iscsi
    parameters:
        openebs.io/jiva-replica-count: "1"
    ```

### Replica Image Policy
You can specify the jiva replica image using the `openebs.io/jiva-replica-image` property.
Jiva replica image is an OpenEBS provided docker image for its storage engine.

1.  Following is a [sample](openebs-mystorageclass2.yaml) intent that makes use of replica image policy:
    
    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
        name: mysql
    provisioner: openebs.io/provisioner-iscsi
    parameters:
        openebs.io/jiva-replica-count: "1"
        openebs.io/capacity: "1G"
        openebs.io/jiva-replica-image: "openebs/jiva:0.6.0"
     ```

### Controller Image Policy
You can specify the jiva controller image using the openebs.io/jiva-controller-image property.

1.  Edit your [storageclass](openebs-mystorageclass3.yaml) file to add the new parameter:

    ```
    kind: StorageClass
    metadata:
        name: mysql
    provisioner: openebs.io/provisioner-iscsi
    parameters:
        openebs.io/jiva-replica-count: "1"
        openebs.io/capacity: "1G"
        openebs.io/jiva-replica-image: "openebs/jiva:0.6.0"
        openebs.io/jiva-controller-image: "openebs/jiva:0.6.0"
    ```

### Storage Pool Policy
A storage pool provides a persistent path for an OpenEBS volume. It can be a directory on any of the following.

- host-os or
- mounted disk/LUN/network share

You must define the storage pool as a Kubernetes Custom Resource (CR) before using it as a Storage Pool policy.

1.  Following is a sample Kubernetes custom resource definition for a storage pool that we have applied in [Exercise 2](../exercise-2/README.md):

    ```
    cd ~/openebs/k8s
    cat openebs-config.yaml
    ```
    
    `openebs-config.yaml` sets the `default` storagepool to path `/var/openebs`
    
    ```
    apiVersion: openebs.io/v1alpha1
    kind: StoragePool
    metadata:
        name: default
        type: hostdir
    spec:
        path: "/var/openebs"
    ```
    
2.  Let's create a new storagepool CR. Copy the `openebs-config.yaml` to [openebs-mystoragepool.yaml](openebs-mystoragepool.yaml) and modify `name` and `path` parameters as follows:
    
    ```
    apiVersion: openebs.io/v1alpha1
    kind: StoragePool
    metadata:
        name: sp-mntdir
        type: hostdir
    spec:
        path: "/mnt/openebs"

3.  This storage pool custom resource can now be used in a storageclass as follows (Example file: [openebs-mystrorageclass4.yaml](openebs-mystrorageclass4.yaml)):

    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
        name: openebs-mystorageclass
    provisioner: openebs.io/provisioner-iscsi
    parameters:
        openebs.io/jiva-replica-count: "3"
        openebs.io/capacity: "3G"
        openebs.io/jiva-replica-image: "openebs/jiva:0.6.0"
        openebs.io/storage-pool: "sp-mntdir"
    ```

### Capacity and FS Type Policy
By default OpenEBS comes with ext4 file system. However, you can specify the file system policy for a particular volume using `openebs.io/fstype` property:

1.  Following is a sample setting used in `openebs-mongodb` storageclass:
    
    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
       name: openebs-mongodb
    provisioner: openebs.io/provisioner-iscsi
    parameters:
      openebs.io/storage-pool: "test-mntdir"
      openebs.io/jiva-replica-count: "1"
      openebs.io/volume-monitor: "true"
      openebs.io/capacity: 5G
      openebs.io/fstype: "xfs"

### Volume Monitoring Policy
You can specify the monitoring policy for a particular volume using openebs.io/volume-monitor property.

1.  The following Kubernetes storageclass sample uses the Volume Monitoring policy:

    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
        name: sc-percona-monitor
    provisioner: openebs.io/provisioner-iscsi
    parameters:
        openebs.io/jiva-replica-image: "openebs/jiva:0.6.0"
        openebs.io/volume-monitor: "true"
    ```
   
### [Continue to Exercise 5 - Configuring Storage Disaggregation with OpenEBS](../exercise-5)
