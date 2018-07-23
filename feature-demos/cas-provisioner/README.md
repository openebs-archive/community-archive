
## Agenda

- Understand use of CAS Template for CRUD operations on a CAS Volume
  - Design - https://docs.google.com/document/d/1SC2U1Xwn0wKQAhwmQNa7QIZjyWICGl_dgxu63ASndUI/
  - PRs:
    - https://github.com/openebs/maya/pull/346
    - https://github.com/openebs/maya/pull/376
    - https://github.com/openebs/external-storage/pull/45


### Setup of Kubernetes & OpenEBS

- Assuming you have a running kubernetes cluster, if not then start single node minikube
    k8s cluster using `minikube.sh` script.
  - run `kubectl get po` to check if kubernetes is up & running

- Deploy openebs components, rbac, cluster role bindings, etc. The operator config file has OPENEBS_IO_CAS_TEMPLATE_FEATURE_GATE
  feature gate enabled by setting the env variable as `true` in deployment of maya-apiserver and openebs-provisioner.
    - `kubectl apply -f openebs-operator.yaml`
    -  Run `kubectl get po` to check if openebs components are up & running

### Setup of CAS Template
- Apply the CAS Template to that is used to create a CAS volume
    - `kubectl apply -f ../cas-templates/crudops/cas-template-create.yaml`
    - `kubectl apply -f ../cas-templates/crudops/cas-template-delete.yaml`
    - `kubectl apply -f ../cas-templates/crudops/cas-template-list.yaml`
    - `kubectl apply -f ../cas-templates/crudops/cas-template-read.yaml`
- Apply CAS Run Tasks that are referred by the CAS Template
    - `kubectl apply -f ../cas-templates/crudops/cas-run-tasks.yaml`

### Create CAS Volume named 'jiva-cas-vol'
- Apply the PVC yaml to create CAS jiva volume
    - `kubectl create -f ../cas-templates/crudops/pvc.yaml`

- Verify creation of CAS volume:
    - `kubectl get deploy`
    - `kubectl get svc`
    - `kubectl get pvc`
    - `kubectl get pv`

### Delete CAS Volume via CAS Template using PVC
- Delete PVC yaml to delete the CAS jiva volume with its deployments.
    - `kubectl delete -f pvc.yaml`

- Verify deletion of CAS volume:
    - `kubectl get deploy`
    - `kubectl get svc`
    - `kubectl get pvc`
    - `kubectl get pv`
