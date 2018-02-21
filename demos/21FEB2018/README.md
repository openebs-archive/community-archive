## Demo to use helm along with openebs

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

### What is helm?


### Steps to use helm  to generate openebs specifications

```bash
# SETUP
$ helm install --debug --dry-run ./ -n autogen --namespace openebs | sed -n '/---/,$p' > openebs-operator-autogen.yaml

# VERIFY


# TEARDOWN


```

### References

- `helm init` installs Tiller into the cluster in the kube-system namespace and without any RBAC rules applied. This is appropriate for local development and other private scenarios because it enables you to be productive immediately. It also enables you to continue running Helm with existing Kubernetes clusters that do not have role-based access control (RBAC) support until you can move your workloads to a more recent Kubernetes version.

