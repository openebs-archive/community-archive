## Agenda

- Understand use of CAS Template for CRUD operations on a CAS Volume
  - Design - https://docs.google.com/document/d/1SC2U1Xwn0wKQAhwmQNa7QIZjyWICGl_dgxu63ASndUI/
  - PRs:
    - https://github.com/openebs/maya/pull/346
    - https://github.com/openebs/maya/pull/376

### Setup of Kubernetes & OpenEBS
- sh minikube.sh
  - run `kubectl get po` to check if kubernetes is up & running
- Deploy openebs components, rbac, cluster role bindings, etc
  - `kubectl apply -f openebs-operator.yaml`
  - run `kubectl get po` to check if openebs components are up & running

## Patch maya api server deployment to 'enable' or 'disable' cas template feature gate
- To enable cas template feature gate
  - kubectl patch deploy maya-apiserver --patch "$(cat cas-template-feature-gate-on.yaml)"
- To disable cas template feature gate
  - kubectl patch deploy maya-apiserver --patch "$(cat cas-template-feature-gate-off.yaml)"

### Setup of CAS Template
- Apply the CAS Template to that is used to create a CAS volume
  - `kubectl apply -f cas-template-create.yaml`
  - `kubectl apply -f cas-template-delete.yaml`
  - `kubectl apply -f cas-template-list.yaml`
  - `kubectl apply -f cas-template-read.yaml`
- Apply CAS Run Tasks that are referred by the CAS Template
  - `kubectl apply -f cas-run-tasks.yaml`

## Curl Commands to Maya API Server
- NOTE: The openebs provisioner can be brought down if we are evaluating maya api server's capabilities via curl commands.
  - `kubectl delete deploy openebs-provisioner`

### Read CAS Volume named 'jiva-cas-vol'
- Try without namespace
  - curl http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol
- Try with namespace
  - curl -H "namespace: default" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol

### Create CAS Volume named 'jiva-cas-vol'
- curl -k -H "Content-Type: application/yaml" \
  -X POST -d"$(cat cas-volume.yaml)" \
  http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/

### Read CAS Volume named 'jiva-cas-vol'
- Try without namespace
  - curl http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol
- Try with namespace
  - curl -H "namespace: default" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol

### List CAS Volumes
- Try without any namespace
  - curl http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/
- Try with a namespace
  - curl -H "namespace: default" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/

### Create another CAS Volume named 'jiva-cas-vol-two' at namespace 'openebs'
- curl -k -H "Content-Type: application/yaml" \
  -X POST -d"$(cat cas-volume-two.yaml)" \
  http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/

### Read CAS Volume named 'jiva-cas-vol-two'
- Try without namespace
  - curl http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol-two
- Try with namespace
  - curl -H "namespace: openebs" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol-two

### List CAS Volumes
- Try without any namespace
  - curl http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/
- Try with a namespace
  - curl -H "namespace: default" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/
  - curl -H "namespace: openebs" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/
  - curl -H "namespace: default, openebs" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/

### Delete a CAS Volume named 'jiva-cas-vol'
- Try without namespace
  - curl -X DELETE http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol

- Try with namespace
  - curl -H "namespace: default" -X DELETE http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol

### Delete CAS Volume named 'jiva-cas-vol-two'
- Try without namespace
  - curl -X DELETE http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol-two

- Try with incorrect namespace
  - curl -H "namespace: default" -X DELETE http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol-two

- Try with correct namespace
  - curl -H "namespace: openebs" -X DELETE http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/jiva-cas-vol-two

### Create CAS Volume via CAS Template using PVC -- FUTURE
- `kubectl apply -f pvc.yaml`
- Verify creation of CAS volume:
  - `kubectl get deploy`
  - `kubectl get svc`
  - `kubectl get pvc`
  - `kubectl get pv`

### Delete CAS Volume via CAS Template using PVC -- FUTURE
- `kubectl delete -f pvc.yaml`
- Verify deletion of CAS volume:
  - `kubectl get deploy`
  - `kubectl get svc`
  - `kubectl get pvc`
  - `kubectl get pv`
