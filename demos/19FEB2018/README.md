## Demo on provisioning openebs volume using rbac

### Agenda
- Provision openebs volume using appropriate rbac policies

### Assumptions
- openebs 0.5.3 release is used
- A kubernetes setup
  - We will use minikube
  - e.g. minikube installed on your local computer with RBAC enabled:
  ```
  minikube start --extra-config=apiserver.Authorization.Mode=RBAC
  ```
  - kubectl is installed
  - NOTE: I destroyed my vagrant VM that had an existing minikube to let these settings be applied
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

### Steps to provision openebs volume using appropriate rbac policies

```bash
# SETUP

# deploy namespaces
kubectl create -f namespaces.yaml

# deploy openebs rbac policies
kubectl create -f oe-rbac.yaml

# deploy openebs operators
kubectl create -f oe-operators.yaml

# deploy openebs crds
kubectl create -f oe-crds.yaml

# deploy openebs objects
kubectl create -f oe-objects.yaml

# deploy user context
sh ./user.sh

# deploy user/app based rbac policies
kubectl create -f app-rbac.yaml

# create openebs volume
kubectl --context=employee-context create -f app.yaml

# VERIFY

$ kubectl get sa --all-namespaces

$ kubectl get crd

$ kubectl get sp

$ kubectl get sc

$ kubectl get po --all-namespaces

$ kubectl get svc --all-namespaces

# TEARDOWN

# delete openebs volume
kubectl --context=employee-context delete -f app.yaml

# delete openebs objects
kubectl delete -f oe-objects.yaml

# delete openebs crds
kubectl delete -f oe-crds.yaml

# delete openebs operators
kubectl delete -f oe-operators.yaml

# delete openebs rbac
kubectl delete -f oe-rbac.yaml

# delete user rbac
kubectl delete -f app-rbac.yaml

# delete the user context
kubectl config delete-context employee-context

# delete custom namespaces
kubectl delete -f namespaces.yaml
```
