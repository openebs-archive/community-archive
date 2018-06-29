## STEPS TO RUN THE DEMO

### Pre-Requisites  

- A Kubernetes cluster >= 1.10 (Ubuntu/CentOs) with one or more nodes. The following vagrant-based cluster was used : 
  (https://github.com/openebs/openebs/tree/master/k8s/vagrant/1.10.0/ubuntu)

### Steps 

- Setup the Local PV storage class 
  (https://github.com/openebs/litmus/blob/master/executor/ansible/provider/local-pv/templates/storage_class.yaml)

- Identify the node & the mounted disk (fs) on which the percona-mysql database can be hosted, i.e., benchmarked
  Kubeminion-01 was used with a locally attached disk filesystem (/mnt/disks/vol1) 

- Setup the Local PV resource 
  (https://github.com/openebs/litmus/blob/master/executor/ansible/provider/local-pv/templates/pv.yaml)

- Setup the Litmus namespace, service account & RBAC 
  (https://github.com/openebs/litmus/blob/master/hack/rbac.yaml)

- Create a configmap with name `kubeconfig` from the ~/.kube/config (or /etc/kubernetes/admin.conf etc..,) 

- Set the APP_NODE_SELECTOR & STORAGE_PROVIDER environment variables in the litmus test job (run_litmus_test.yaml)
  (https://github.com/openebs/litmus/blob/master/tests/mysql/mysql_storage_benchmark/run_litmus_test.yaml)

  APP_NODE_SELECTOR=kubeminion01, STORAGE_PROVIDER=local-storage 
 
- Run the litmus test job `kubectl apply -f run_litmus_test.yaml` 

### Execution 

The test lauches the litmus pod (with test container & logger), which in-turn launches the application pod, percona.
The percona pod includes a sidecar which runs the benchmark workload upon obtaining database server connectivity. 

The test pods are cleaned up on completion of the run 

### Logs 

- The test run logs are placed inside the "/mnt" folder on the node in which Litmus test pod is scheduled. These include: 

  - Ansible Test Playbook run logs (/mnt/host/127.0.0.1)
  - Cluster info, pod logs (/mnt/Logstash_<timestamp>_.tar)

### Results

- The benchmark number (tpmC: Transactions Per Minute) can be obtained from the TPCC benchmark container (sidecar) logs 

  `kubectl logs percona -c tpcc-bench p-n litmus` (or from the percona.log in the log bundle) 

**Note** The results infrastructure is being worked on & will be available in the Litmus 0.1 release 

### Conclusion

The purpose of this test is to enable users to compare w/ different underlying storage. The above test can be repeated w/ 
OpenEBS by installing the openebs operator & re-running the litmus job with the `openebs-standard` storage class.

Note: The existing litmus job has to be cleaned up before re-running 

With the same workload run as part of the demo, the numbers obtained were are follows: 

Local PV : 1474.000 TpmC
OpenEBS  : 982.500 TpmC






