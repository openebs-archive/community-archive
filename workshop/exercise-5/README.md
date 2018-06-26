# Exercise 5 - Configuring Storage Disaggregation with OpenEBS

OpenEBS uses Hyper-Converged mode by default, unless configured otherwise. If it's required by the architect, for different use-case  Disaggreagated Storage architecture aka Hyperscale mode can be applied to OpenEBS.

One use-case is where user has only certain nodes that have disks attached. Let's call these as Storage Nodes. You may want the OpenEBS Volume Replica Pods to be scheduled on these Storage Nodes.

As per [Kubernetes docs](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/), taints allow a node to repel a set of pods. Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes.

- You can apply `NoSchedule` & `NoExecute` taints to the node(s).
- `NoSchedule` marks that the node should not schedule any pods that do not tolerate the taint.
- `NoExecute` marks that the node should evict existing/running pods that do not tolerate this taint.
- Tolerations are applied to pods, and allow the pods to get scheduled onto nodes with matching taints.
- You need to set an ENV variable in maya API server Deployment specifications, which in turn ensures setting of above tolerations on the replica pods.
- The ENV variable referred to here is `DEFAULT_REPLICA_NODE_TAINT_TOLERATION`

## Tainting the node(s)

You will taint the Storage Nodes where you want OpenEBS replica pods to be scheduled. This means that no pod will be able to schedule onto that specific node unless it has a matching toleration. 

1.  Replace the `kubeminion-01` with the name of your Kubernetes node. The taint effects used here are `NoSchedule` and `NoExecute`.

    ```
    kubectl taint nodes kubeminion-01 storage=ssd:NoSchedule storage=ssd:NoExecute
    ```

2.  We will ensure the OpenEBS replica pods are set with appropriate tolerations. Edit the `openebs-operator.yaml` and locate the section describing the Deployment. Add the `env` parameters for Maya API server to be deployed with below specs: 

    ```
    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
     name: maya-apiserver
    spec:
     replicas: 1
     template:
      metadata:
       labels:
        name: maya-apiserver
     spec:
       serviceAccountName: openebs-maya-operator
       containers:
       —  name: maya-apiserver
         imagePullPolicy: Always
         image: openebs/m-apiserver:0.6.0
         ports:
         —  containerPort: 5656
         env:
         —  name: DEFAULT_REPLICA_NODE_TAINT_TOLERATION
           value: storage=ssd:NoSchedule,storage=ssd:NoExecute
    ```

3.  Apply the `openebs-operator.yaml`.

    ```
    kubectl apply -f openebs.operator.yaml
    ```

## Allow workloads to be schedule on the Storage Nodes

To be able to achieve better utilisation of these Storage nodes by scheduling your application Pods on these nodes as well we can use Kubernetes `PreferNoSchedule` as the taint effect.
This parameter can be considered as a soft version of `NoSchedule`. In other words the Kubernetes scheduler tries to avoid placing a pod that does not tolerate the taint on the node, but it is not mandatory.

1.  Replace the `kubeminion-01` with the name of your Kubernetes node. The taint effects used here is `PreferNoSchedule`.

    ```
    kubectl taint nodes kubeminion-01 storage=ssd:PreferNoSchedule
    ```

2.  We will ensure the OpenEBS replica pods are set with appropriate tolerations. Edit the `openebs-operator.yaml` and locate the section describing the Deployment. Add the `env` parameters for Maya API server to be deployed with below specs: 
    
    ```
    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
     name: maya-apiserver
     namespace: default
    spec:
     replicas: 1
     template:
      metadata:
       labels:
        name: maya-apiserver
      spec:
       serviceAccountName: openebs-maya-operator
       containers:
       —  name: maya-apiserver
         imagePullPolicy: Always
         image: openebs/m-apiserver:0.6.0
         ports:
         —  containerPort: 5656
         env:
         — name: DEFAULT_REPLICA_NODE_TAINT_TOLERATION
           value: storage=ssd:PreferNoSchedule
     ```

3.  Apply the `openebs-operator.yaml`.

    ```
    kubectl apply -f openebs.operator.yaml
    ```

Credit: Thanks to Amit Das for his article published on [openebs.blog.io](https://blog.openebs.io/how-do-i-configure-openebs-to-use-storage-on-specific-kubernetes-nodes-361e3e842a78).
   
### [Continue to Exercise 6 - Monitoring OpenEBS using Prometheus and Grafana](../exercise-6)
