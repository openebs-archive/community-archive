## Demo done on 16th Feb 2018 at OpenEBS Contributors Weekly

### Agenda
- Configuring StoragePool using VolumePolicy
- Enabling/Disabling openebs volume monitoring using VolumePolicy
- Configuring ReplicaCount using VolumePolicy

### Assumptions
- openebs/maya's master branch is being used
- A kubernetes setup
  - We will use minikube
- Basic knowledge of:
  - Kubernetes StorageClass
  - Kubernetes CRD
  - Kubernetes ConfigMap
  - Kubernetes Deployment
  - Kubernetes Service

### What is a storage pool?
- Storage pool is a concept defined by openebs
- It is a Kubernetes CustomResource
- It provides a persistent path for an OpenEBS volume. It can be a directory on:
  - host-os or
  - mounted disk

### What is a volume monitoring?
- Volume monitoring is used to monitor openebs volumes
- It makes use of Kubernetes sidecar pattern
- It is deployed as a sidecar container along with openebs controller
- It exposes metrics to Prometheus

### What is volume replica count?
- OpenEBS has the concept of replicas
- Replicas persist the IO on configured storage pool (refer above)
- It is advisable to have a replica count of 3 to ensure high availability

### Steps to configure StoragePool using VolumePolicy

```bash
# deploy openebs operator components
kubectl create -f operator.yaml

# deploy openebs volume policies
kubectl create -f vol-policies.yaml

# use the cluster IP to invoke curl commands to maya api server
kubectl get svc maya-apiserver-service

# create the openebs volume
curl -k -H "Content-Type: application/yaml" -XPOST -d"$(cat oe-vol-std-060.yaml)" \
  http://$clusterIP:5656/v1alpha1/volumes/

# delete the openebs volume
curl http://$clusterIP:5656/latest/volumes/delete/jivavolpol

# delete openebs volume policies
kubectl delete -f vol-policies.yaml

# delete openebs operator components
kubectl delete -f operator.yaml
```

### Steps to enable volume monitoring using VolumePolicy
```bash
# deploy openebs operator components
kubectl create -f operator.yaml

# deploy openebs volume policies
kubectl create -f vol-policies.yaml

# use the cluster IP to invoke curl commands to maya api server
kubectl get svc maya-apiserver-service

# create the openebs volume
curl -k -H "Content-Type: application/yaml" -XPOST -d"$(cat oe-vol-mon-on-060.yaml)" \
  http://$clusterIP:5656/v1alpha1/volumes/

# delete the openebs volume
curl http://$clusterIP:5656/latest/volumes/delete/jivavolpol

# delete openebs volume policies
kubectl delete -f vol-policies.yaml

# delete openebs operator components
kubectl delete -f operator.yaml
```

### Steps to disable volume monitoring using VolumePolicy
```bash
# deploy openebs operator components
kubectl create -f operator.yaml

# deploy openebs volume policies
kubectl create -f vol-policies.yaml

# use the cluster IP to invoke curl commands to maya api server
kubectl get svc maya-apiserver-service

# create the openebs volume
curl -k -H "Content-Type: application/yaml" -XPOST -d"$(cat oe-vol-mon-off-060.yaml)" \
  http://$clusterIP:5656/v1alpha1/volumes/

# delete the openebs volume
curl http://$clusterIP:5656/latest/volumes/delete/jivavolpol

# delete openebs volume policies
kubectl delete -f vol-policies.yaml

# delete openebs operator components
kubectl delete -f operator.yaml
```

### Steps to configure replica count using VolumePolicy
```bash
# deploy openebs operator components
kubectl create -f operator.yaml

# deploy openebs volume policies
kubectl create -f vol-policies.yaml

# use the cluster IP to invoke curl commands to maya api server
kubectl get svc maya-apiserver-service

# create the openebs volume
curl -k -H "Content-Type: application/yaml" -XPOST -d"$(cat oe-vol-ha-060.yaml)" \
  http://$clusterIP:5656/v1alpha1/volumes/

# delete the openebs volume
curl http://$clusterIP:5656/latest/volumes/delete/jivavolpol

# delete openebs volume policies
kubectl delete -f vol-policies.yaml

# delete openebs operator components
kubectl delete -f operator.yaml
```
