## Agenda

- Pin volume replica to K8s node
  - Issue - https://github.com/openebs/openebs/issues/1310
  - PR - 

NOTE: This will work once above PR is merged!

### Assumptions
- openebs/maya's master branch is being used
- A kubernetes setup
  - We will use minikube
  - NOTE: A multi-node cluster will be better to verify this behaviour
- Basic knowledge of:
  - Kubernetes Pod
  - Kubernetes PersistentVolumeClaim
  - Kubernetes StorageClass
  - Kubernetes CRD
  - Kubernetes ConfigMap
  - Kubernetes Deployment
  - Kubernetes Service
  - Kubernetes Patch
  - Kubernetes Node Affinity

### What is nodeAffinity?
- Node affinity is conceptually similar to nodeSelector
- It allows you to constrain which nodes your pod is eligible to be scheduled on
- It is based on labels on the node
- There are currently two types of node affinity:
  - requiredDuringSchedulingIgnoredDuringExecution &
  - preferredDuringSchedulingIgnoredDuringExecution
- These node affinity types can be thought of “hard” vs. “soft” affinity respectively

### Why does OpenEBS need nodeAffinity?
- OpenEBS volume replicas need to be sticky to the nodes where they got scheduled
- It is not convinient to move data across nodes if replicas keep moving around

### Why not nodeSelector?
- node affinity is more expressive than nodeSelector
- node affinity can specify requirements better than nodeSelector
- nodeSelector will be deprecated in favour of node affinity

### Sample Specifications

- sample volumepolicy snippet:
```yaml
  run:
    searchNamespace: default
    tasks:
    - template: volume-service-0.6.0
      identity: vsvc
    - template: volume-path-0.6.0
      identity: vpath
    - template: volume-pvc-0.6.0
      identity: vpvc
    - template: volume-controller-0.6.0
      identity: vctrl
    - template: volume-replica-0.6.0
      identity: vrep
    - template: volume-replica-list-0.6.0
      identity: vreplist
    - template: volume-replica-patch-0.6.0
      identity: vreppatch
```

- sample volume replica list template:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: volume-replica-list-0.6.0
  annotations:
    openebs.io/policy: VolumePolicy
    policy.openebs.io/version: 0.6.0
  namespace: default
data:
  meta: |
    runNamespace: {{ .Volume.runNamespace }}
    apiVersion: v1
    kind: Pod
    action: list
    options: |-
      labelSelector: openebs.io/replica=jiva-replica,openebs.io/pv={{ .Volume.owner }}
    queries:
    - alias: objectName
    - alias: nodeNames
      path: |-
        {.items[*].spec.nodeName}
      verify:
        split: " "
        count: {{ .Policy.ReplicaCount.value }}
```

- sample volume replica patch template:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: volume-replica-patch-0.6.0
  annotations:
    openebs.io/policy: VolumePolicy
    policy.openebs.io/version: 0.6.0
  namespace: default
data:
  meta: |
    runNamespace: {{ .Volume.runNamespace }}
    apiVersion: extensions/v1beta1
    kind: Deployment
    objectName: {{ .Volume.owner }}-rep
    action: patch
    patches: |-
      spec:
        template:
          spec:
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                  - matchExpressions:
                    - key: kubernetes.io/hostname
                      operator: In
                      values:
                      {{- $nodeNamesMap := .TaskResult.vreplist.nodeNames | split " " }}
                      {{- range $k, $v := $nodeNamesMap }}
                      - {{ $v }}
                      {{- end }}
                  - $patch: merge
```

#### SETUP
```bash
# Deploy kubectl, minikube, helm, & openebs charts
sh ./setup.sh

# Customize openebs operator
cd .tmp/openebs && \
  helm install --debug --dry-run ./ \
  --name ci \
  --set apiserver.imageTag="1310",apiserver.replicas="1",provisioner.replicas="1" \
  | sed -n '/---/,$p' > openebs-operator-autogen.yaml && \
  cd ../..

# NOTE: Remove openebs provisioner deployment from above autogen file
This is done to test the replica pinning logic via maya api server only

# View the operator file & verify its correctness
cat .tmp/openebs/openebs-operator-autogen.yaml

# Deploy openebs operator components
kubectl create -f crds.yaml
kubectl create -f .tmp/openebs/openebs-operator-autogen.yaml

# Deploy openebs volume policies
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
  -d"$(cat oe-vol-rep-pinning-060.yaml)" \
  http://"$(kubectl get svc -n openebs ci-openebs-maya-apiservice --template={{.spec.clusterIP}})":5656/v1alpha1/volumes/

# VERIFY if controller & replica pods & volume service are running or available


# DELETE the openebs volume using /latest/ URL path
curl -H "namespace: default" http://"$(kubectl get svc -n openebs ci-openebs-maya-apiservice --template={{.spec.clusterIP}})":5656/latest/volumes/delete/jivavolpol
```

#### TEARDOWN
```bash
# 1/ delete openebs volume policies
kubectl delete -f vol-policies.yaml

# 2/ delete openebs operator components
kubectl delete -f .tmp/openebs/openebs-operator-autogen.yaml
kubectl delete -f crds.yaml
```

### Troubleshooting

#### Issue 1:
Inter-pod affinity and anti-affinity require substantial amount of processing which can slow down scheduling in large clusters significantly. We do not recommend using them in clusters larger than several hundred nodes.

### References
- https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/util/jsonpath/jsonpath_test.go
- https://github.com/Masterminds/sprig/blob/master/doc.go
- https://github.com/kubernetes/community/blob/master/contributors/devel/strategic-merge-patch.md
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apimachinery/pkg/util/strategicpatch/patch_test.go
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apimachinery/pkg/apis/meta/v1/types.go

### Extras
- Understand patch using kubectl in verbose mode
```bash
kubectl create -f mock_deployment.yaml
kubectl patch deployment nginx -p "$(cat mock_patch.yaml)" --v=9
kubectl patch deployment nginx -p "$(cat mock_patch_2.yaml)" --v=9
```
