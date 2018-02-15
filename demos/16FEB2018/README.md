## Demo done on 16th Feb 2018 at OpenEBS Contributors Weekly

### Agenda
- Configuring StoragePool using VolumePolicy
- Enabling/Disabling openebs volume monitoring using VolumePolicy

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

### What is a StoragePool?
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

### Steps to configure StoragePool using VolumePolicy

### Steps to enable volume monitoring using VolumePolicy

### Steps to disable volume monitoring using VolumePolicy
