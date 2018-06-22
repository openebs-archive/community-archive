# Prerequisites - Getting started with a local Kubernetes setup 

Minimum requirements to run Minikube locally:

## Hardware
- Machine Type – minimum 4 vCPUs.
- RAM – minimum 4 GB.
- VT-x/AMD-v virtualization must be enabled in your system BIOS

## Software
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

If using macOS:
- xhyve driver, 
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads), or VMware Fusion.

If using Linux:
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) or KVM.

NOTE: Minikube supports the `--vm-driver=none` option that runs Kubernetes components on the host and not in a VM. Docker is required to use this driver, but not the hypervisor.

If using Windows:
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) or Hyper-V. VMware Workstation is not supported.

Since VirtualBox is available on all three platforms, we will describe this option.

## Install VirtualBox
We will not cover the details of VirtualBox installation since it is very common and instructions are widely available online.

1.  Go to the Virtualbox website.

2.  Download and install the binaries required for your operating system.

3.  Make sure that you install VirtualBox 5.2.0 Oracle VM VirtualBox Extension Pack as well.

At the time i wrote this article, the most current version was VirtualBox-5.2.0-118431.

Once VirtualBox is installed, you will see a screen similar to the following:

## Install Ubuntu
1.  Create a new VM with 4 vCPUs, 4Gb memory, and 10GB disk space.

2.  Download your preferred version of Ubuntu. I will be using Ubuntu 16.04.3 LTS.

3.  Under VM Settings/Storage, mount your ISO image and power on the VM.

4.  Install Ubuntu with default options. I used `openebs/password` as `username/password` for simplicity. If you use something else make sure to replace it with yours when you follow the instructions.

5.  Finally login to your Ubuntu VM.

6.  On your Ubuntu host, install the SSH server:

    ```
    sudo apt-get install openssh-server
    ```

7.  Now you should be able to access your VM using SSH. Check the status by running:

    ```
    sudo service ssh status
    ```
   
8.  Disable firewall on your Ubuntu VM by running:
    
    ```
    sudo ufw disable
    ```
    
9.  Install curl if it’s not already installed:

    ```
    sudo apt install curl
    ```
    
10.  By default, for each virtual machine, VirtualBox creates a private network (10.0.2.x) which is connected to your laptop’s network using NAT. However, you may not be able to your VMs from your local host through SSH just yet. To access your VM, you need to configure port forwarding. In the network setting of the VM. Click on Advanced/Port Forwarding and create a rule with the Host port 3022 and Guest Port 22. Name it SSH and leave other fields blank.

11.  Now you can connect to your Ubuntu VM from your laptop using SSH with localhost as the address and port 3022 instead of 22. Connect to your Ubuntu VM using the following credentials: `openebs/password`

## Install Docker
To get the latest version of Docker, install it from the official Docker repository.

1.  On your Ubuntu VM, run the following commands:

    ```~curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    ```

2.  Confirm that you want to install the binaries from the Docker repository instead of the default Ubuntu repository by running:

    ```
    sudo apt-get install -y docker-ce
    ```

3.  Install Docker and make sure it’s up and running after installation is complete:

    ```sudo apt-get install -y docker-ce
    sudo systemctl status docker
    ```

## Add iSCSI Support
OpenEBS uses iSCSI to connect to the block volumes. Therefore, you need to install the open-iscsi package on your Ubuntu machine.

1.  On your Ubuntu host, run:

    ```
    sudo apt-get update
    sudo apt-get install open-iscsi
    sudo service open-iscsi restart
    ```

2.  Check that the iSCSI initiator name is configured:
    
    ```
    sudo cat /etc/iscsi/initiatorname.iscsi
    ```
    
3.  Verify the iSCSI service is up and running:
    
    ```
    sudo service open-iscsi status
    ```

## Set up minikube and kubectl
1.  On your Ubuntu host, install minikube by running:

    ```curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube
    sudo mv minikube /usr/local/bin/
    ```

2.  Install kubectl:
    
    ```curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    ```

3.  Set up directories for storing minkube and kubectl configurations:
    
    ```
    mkdir $HOME/.kube || true touch $HOME/.kube/config
    ```

4.  Set up an environment for minikube by adding the following lines to the end of the ~/.profile file:
    
    ```export MINIKUBE_WANTUPDATENOTIFICATION=false
    export MINIKUBE_WANTREPORTERRORPROMPT=false
    export MINIKUBE_HOME=$HOME
    export CHANGE_MINIKUBE_NONE_USER=true
    export KUBECONFIG=$HOME/.kube/config
    ```

5.  Confirm that environment variables are saved in your profile file:

    ```
    cat ~/.profile
    ```

6.  Start minikube:
    
    ```
    sudo -E minikube start --vm-driver=none
    ```

7.  If you forgot to install Docker, you will get an error.
When using the none driver, the kubectl config and credentials generated will be root-owned and will appear in the root home directory. To fix this, set the correct permissions:

    ```sudo chown -R $USER $HOME/.kube
    sudo chgrp -R $USER $HOME/.kube
    sudo chown -R $USER $HOME/.minikube
    sudo chgrp -R $USER $HOME/.minikube
    ```

8.  Verify that minikube is configured correctly and it has started by running:

    ```
    minikube status
    ```

9.  Verify Kubernetes configuration
Check that kubectl is configured and services are up and running by getting the list of Kubernetes nodes and pods:

    ```
    kubectl get nodes
    kubectl get pods --all-namespaces
    ```
   
## Clone the lab repo

From your command line, run:
   
```bash   
git clone https://github.com/openebs/workshop

cd openebs/workshop
```

This is the working directory for the workshop. You use the example `.yaml` files that are located in the _workshop/plans_ directory in the following exercises.

### [Continue to Exercise 1 - Accessing and validating your Kubernetes cluster](../exercise-1/README.md)
