## Agenda

- Understand use of CAS Template for CRUD operations on a CAS Volume
  - Design - https://docs.google.com/document/d/1SC2U1Xwn0wKQAhwmQNa7QIZjyWICGl_dgxu63ASndUI/
  - PRs:
    - https://github.com/openebs/maya/pull/346

### Setup of Kubernetes & OpenEBS
- sh minikube.sh
  - run `kubectl get po` to check if kubernetes is up & running
- Deploy openebs components, rbac, cluster role bindings, etc
  - `kubectl apply -f openebs-operator.yaml`
  - run `kubectl get po` to check if openebs components are up & running

### Setup of CAS Template
- Apply the CAS Template to that is used to create a CAS volume
  - `kubectl apply -f cas-template-create.yaml`
- Apply CAS Run Tasks that are referred by the CAS Template
  - `kubectl apply -f cas-run-tasks.yaml`

### Create CAS Volume
- `kubectl apply -f pvc.yaml`
- Verify creation of CAS volume:
  - `kubectl get deploy`
  - `kubectl get svc`
  - `kubectl get pvc`
  - `kubectl get pv`

### Delete CAS Volume
- `kubectl delete -f pvc.yaml`
- Verify deletion of CAS volume:
  - `kubectl get deploy`
  - `kubectl get svc`
  - `kubectl get pvc`
  - `kubectl get pv`

