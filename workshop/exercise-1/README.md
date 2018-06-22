# Exercise 1 - Accessing and validating your Kubernetes cluster

In this workshop we will execute some commands Kubernetes master nodes, therefore you need to SSH into your K8s nodes to run some of the validation steps, but after that you can either use kubectl on your local laptop (recommended way) or continue to run the commands on the Kubernetes master node.  

## Optional: Install and configure kubectl to access K8s cluster remotely 

If you'd like to use Kubernetes command-line tool, kubectl, to remotely manage applications on Kubernetes, then follow the instructions below. Using kubectl, you can inspect cluster resources; create, delete, and update components; and look at your new cluster and bring up example apps.

1.  Install it via your OS's native package management

    For Ubuntu/Debian:

    ```
    apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    apt-get update
    apt-get install -y kubectl
    ```

    For other O/S follow the instruction [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) and install kubectl on your local laptop. 

2.  Set up config via environment variables

    ```
    export KUBECONFIG=/path/to/kubeconfig
    ```

## Verify Kubernetes configuration

1.  Check that kubectl is configured and services are up and running by getting the list of Kubernetes nodes and pods:

    ```
    kubectl get nodes
    kubectl get pods --all-namespaces
    ```
    Note the number of non-master nodes you have. You need to know how many replicas you can schedule on seperate nodes.  
    By default, your cluster will not schedule pods on the master for security reasons. If you want to be able to schedule pods on the master, e.g. for a single-machine Kubernetes cluster for development, run:

    ```
    kubectl taint nodes --all node-role.kubernetes.io/master-
    ```

## Verify iSCSI Support

This step needs to be executed local on the Kubernetes nodes. OpenEBS uses iSCSI to connect to the block volumes. Select one of the nodes in the cluster and SSH into it.

1.  Check if the initiator name is configured.

    ```
    $ sudo cat /etc/iscsi/initiatorname.iscsi
    ## DO NOT EDIT OR REMOVE THIS FILE!
    ## If you remove this file, the iSCSI daemon will not start.
    ## If you change the InitiatorName, existing access control lists
    ## may reject this initiator.  The InitiatorName must be unique
    ## for each iSCSI initiator.  Do NOT duplicate iSCSI InitiatorNames.
    InitiatorName=iqn.1993-08.org.debian:01:6277ea61267f
    ```

2.  Check if the iSCSI service is running.

    ```
    $ sudo service open-iscsi status
     ● open-iscsi.service - Login to default iSCSI targets
        Loaded: loaded (/lib/systemd/system/open-iscsi.service; enabled; vendor preset: enabled)
       Active: active (exited) since Wed 2018-06-13 20:33:59 UTC; 48min ago
         Docs: man:iscsiadm(8)
               man:iscsid(8)
     Main PID: 1237 (code=exited, status=0/SUCCESS)
        Tasks: 0
       Memory: 0B
          CPU: 0
       CGroup: /system.slice/open-iscsi.service
    
    Jun 13 20:33:59 ip-172-23-1-144 iscsiadm[1222]: iscsiadm: No records found
    Jun 13 20:33:59 ip-172-23-1-144 systemd[1]: Starting Login to default iSCSI targets...
    Jun 13 20:33:59 ip-172-23-1-144 systemd[1]: Started Login to default iSCSI targets.
    ```

Repeat steps 1 and 2 for the remaining nodes.
   
### [Continue to Exercise 2 - Installing OpenEBS](../exercise-2)
