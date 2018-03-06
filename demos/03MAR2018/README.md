## Agenda
- Configure Taints & Tolerations using VolumePolicy
  - Issue - https://github.com/openebs/openebs/issues/1304
  - PR- https://github.com/openebs/maya/pull/277

NOTE: This will work once above PR is merged!

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

### What is taints & tolerations?
Operator might want to dedicate nodes for volume pod controllers & volume pod replicas.
e.g.
- operator will taint the node as follows:
```bash
kubectl taint nodes node1 ssd=yes:NoExecute
kubectl taint nodes node1 ssd=yes:NoSchedule
```
- volume pods (replica &/or controller) need to tolerate above taints as follows:
```yaml
tolerations:
- key: "ssd"
  operator: "Equal"
  value: "yes"
  effect: "NoSchedule"
- key: "ssd"
  operator: "Equal"
  value: "yes"
  effect: "NoExecute"
```

### Taints & Tolerations using VolumePolicy

#### SETUP
```bash
# deploy kubectl, minikube, helm, & openebs charts
sh ./setup.sh

# customize openebs operator
cd .tmp/openebs && \
  helm install --debug --dry-run ./ \
  --name ci \
  --set apiserver.imageTag="ci",apiserver.replicas="1",provisioner.replicas="1" \
  | sed -n '/---/,$p' > openebs-operator-autogen.yaml && \
  cd ../..

# view the operator file & verify its correctness
cat .tmp/openebs/openebs-operator-autogen.yaml

# deploy openebs operator components
kubectl create -f crds.yaml
kubectl create -f .tmp/openebs/openebs-operator-autogen.yaml

# deploy openebs volume policies
# NOTE: Read this yaml to understand the volume policy details
# - Shows how to use volume policy as a task workflow
# - Shows how a volume policy uses templates as its tasks
kubectl create -f vol-policies.yaml
```

#### RUN
```bash
# Use maya apiserver service cluster IP
kubectl get svc --all-namespaces

# ADD openebs volume using /v1alpha1/ URL path

curl -k -H "Content-Type: application/yaml" -XPOST \
  -d"$(cat oe-vol-taints-060.yaml)" \
  http://"$(kubectl get svc -n openebs ci-openebs-maya-apiservice --template={{.spec.clusterIP}})":5656/v1alpha1/volumes/

# VERIFY if controller & replica pods & volume service are running or available


# DELETE the openebs volume using /latest/ URL path
curl -H "namespace: default" http://"$(kubectl get svc -n openebs ci-openebs-maya-apiservice --template={{.spec.clusterIP}})":5656/latest/volumes/delete/jivavolpol
```

#### TEARDOWN
```bash
# delete openebs volume policies
kubectl delete -f vol-policies.yaml

# delete openebs operator components
kubectl delete -f .tmp/openebs/openebs-operator-autogen.yaml
kubectl delete -f crds.yaml
```

### Troubleshooting

#### Issue 1:
```bash
volumepolicies.openebs.io "openebs-policy-taints-0.6.0" is forbidden: User "system:serviceaccount:openebs:openebs-maya-operator" cannot get volumepolicies.openebs.io at the cluster scope
```

- Solution: 
  - Add volumepolicies as a resource in ClusterRole
  - Check the openebs-operator-autogen.yaml file

#### Issue 2:
```bash
configmaps "volume-service-0.6.0" is forbidden: User "system:serviceaccount:openebs:openebs-maya-operator" cannot get configmaps in the namespace "openebs"
```

- Solution:
  - Add configmaps as a resource in ClusterRole
  - Check the openebs-operator-autogen.yaml file
