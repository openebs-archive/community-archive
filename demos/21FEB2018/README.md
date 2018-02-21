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
# INSTALL
# Ensure that socat is installed
# This is used between helm to kubernetes communication
sudo apt-get install socat

# Download & install helm
curl -Lo /tmp/helm-linux-amd64.tar.gz \
  https://kubernetes-helm.storage.googleapis.com/helm-v2.6.2-linux-amd64.tar.gz
tar -xvf /tmp/helm-linux-amd64.tar.gz -C /tmp/
chmod +x  /tmp/linux-amd64/helm && sudo mv /tmp/linux-amd64/helm /usr/local/bin/

# Initialize helm
helm init

# Verify helm is running by checking the tiller deploy
$ kubectl get deploy --all-namespaces
NAMESPACE     NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   kube-dns               1         1         1            0           2d
kube-system   kubernetes-dashboard   1         1         1            0           2d
kube-system   tiller-deploy          1         1         1            1           25s

# Setup RBAC for tiller
# Create a service account in the namespace kube-system
kubectl -n kube-system create sa tiller

# Enable cluster admin role
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# Update the deployment to set the above created service account
kubectl -n kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'
```

```bash
# SETUP
$ helm install --debug --dry-run ./ -n autogen --namespace openebs | sed -n '/---/,$p' > openebs-operator-autogen.yaml

# VERIFY


# TEARDOWN


```

### References

- `helm init` installs Tiller into the cluster in the kube-system namespace and without any RBAC rules applied. This is appropriate for local development and other private scenarios because it enables you to be productive immediately. It also enables you to continue running Helm with existing Kubernetes clusters that do not have role-based access control (RBAC) support until you can move your workloads to a more recent Kubernetes version.

