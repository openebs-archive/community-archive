## Agenda

- Pin volume controller to run alongside the application POD
  - i.e. best effort scheduling to let `volume controller` & `application` PODs 
run in the same topology key e.g. same K8s node
  - Issue - https://github.com/openebs/openebs/issues/1257
  - PR - https://github.com/openebs/maya/pull/278

NOTE: This will work once above PR is merged!

### Assumptions
- openebs/maya's master branch is being used
- A kubernetes setup
  - We will use minikube
  - NOTE: A multi-node cluster will be better to verify this behaviour
- Basic knowledge of:
  - Kubernetes PersistentVolumeClaim
  - Kubernetes StorageClass
  - Kubernetes CRD
  - Kubernetes ConfigMap
  - Kubernetes Deployment
  - Kubernetes Service

### What is inter pod affinity?
Inter pod affinity is used to let two or more PODs be scheduled to the same 
topology key e.g. same K8s node

Inter-pod affinity allow you to constrain which nodes your pod is eligible to be
scheduled based on labels on pods that are already running on the node rather 
than based on labels on nodes. 

There are currently two types of pod affinity:
  1/ requiredDuringSchedulingIgnoredDuringExecution and 
  2/ preferredDuringSchedulingIgnoredDuringExecution 
which denote “hard” vs. “soft” requirements.

It is to be noted that the above hard requirement will put the volume controller
pod into a pending state till the application pod is not created.

### How does OpenEBS specify pod affinity with the application workload?
- openebs volume controller sets the pod affinity policies based on:
  - the labels set in the application workload as well as
  - the annotations in the PVC this application workload refers to

#### Application & PVC specifications
- the application pod specs should have a label that matches this affinity
  - i.e. `controller.openebs.io/affinity: unique-app-label-value`
- The application specs should try to provide a unique label value for the label
key `controller.openebs.io/affinity`
- The application specs can also provide the topologyKey to be considered 
for pod affinity. 
  - This topology key can be set in the application specifications labels
  - i.e. `controller.openebs.io/affinity-topology: kubernetes.io/hostname`
- If topologyKey is not provided then volume controller pod affinity will default 
to `kubernetes.io/hostname`
- Finally above affinity & affinity-topology labels needs to be present as 
annotations in the PVC that this application refers to.


### Sample Specifications

- sample application specifications:
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: jenkins
spec:
 replicas: 1
 template:
  metadata:
   labels:
    app: jenkins-app
    controller.openebs.io/affinity: mypin
    controller.openebs.io/affinity-topology: kubernetes.io/hostname
  spec:
   securityContext:
     fsGroup: 1000
   containers:
   - name: jenkins
     imagePullPolicy: IfNotPresent
     image: jenkins/jenkins:lts
     ports:
     - containerPort: 8080
     volumeMounts:
     - mountPath: /var/jenkins_home
       name: jenkins-home 
   volumes: 
   - name: jenkins-home
     persistentVolumeClaim: 
      claimName: openebs-podaffinity-0.6.0
```

- sample pvc specifications:
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: openebs-podaffinity-0.6.0
  annotations:
    controller.openebs.io/affinity: mypin
    controller.openebs.io/affinity-topology: kubernetes.io/hostname
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi
  storageClassName: openebs-podaffinity-0.6.0
```

- sample volumepolicy specifications:
```yaml
apiVersion: openebs.io/v1alpha1
kind: VolumePolicy
metadata:
  name: openebs-policy-podaffinity-0.6.0
spec:
  policies:
  - name: VolumeMonitor
    enabled: "true"
  - name: ControllerImage
    value: openebs/jiva:0.5.0
  - name: ReplicaImage
    value: openebs/jiva:0.5.0
  - name: ReplicaCount
    value: "1"
  - name: StoragePool
    value: ssd
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
```

- sample volume configmap template that fetches pod affinity annotations from pvc:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: volume-pvc-0.6.0
  annotations:
    openebs.io/policy: VolumePolicy
    policy.openebs.io/version: 0.6.0
  namespace: default
data:
  meta: |
    runNamespace: {{ .Volume.runNamespace }}
    apiVersion: v1
    kind: PersistentVolumeClaim
    objectName: {{ .Volume.pvc }}
    action: get
    queries:
    - alias: objectName
      path: |-
        {.metadata.name}
    - alias: affinity
      path: |-
        {.metadata.annotations.controller\.openebs\.io/affinity}
    - alias: affinityTopology
      path: |-
        {.metadata.annotations.controller\.openebs\.io/affinity-topology}
```

- sample volume controller template snippet:
```yaml
        spec:
          {{- if ne .TaskResult.vpvc.affinity "" }}
          affinity:
            podAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                  - key: controller.openebs.io/affinity
                    operator: In
                    values:
                    - {{ .TaskResult.vpvc.affinity }}
                topologyKey: {{ .TaskResult.vpvc.affinityTopology | default "kubernetes.io/hostname" }}
          {{- end }}
```

#### SETUP
```bash
# deploy kubectl, minikube, helm, & openebs charts
sh ./setup.sh

# customize openebs operator
cd .tmp/openebs && \
  helm install --debug --dry-run ./ \
  --name ci \
  --set apiserver.imageTag="1257",apiserver.replicas="1",provisioner.replicas="1" \
  | sed -n '/---/,$p' > openebs-operator-autogen.yaml && \
  cd ../..

# Remove openebs provisioner deployment from above autogen file
This is done to test the controller pinning logic via maya api server only

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
Inter-pod affinity and anti-affinity require substantial amount of processing which can slow down scheduling in large clusters significantly. We do not recommend using them in clusters larger than several hundred nodes.
