# Prerequisites - Getting started on AWS using StackPointCloud managed Kubernetes setup 

Minimum requirements to quickly run your Kubernetes cluster on cloud:

## Cloud Provider
- AWS account (Other major providers supported by StackPoint, but not covered in this article)

## Start your StackPoint Trial

1. First, go to [stackpoint.io](https://stackpoint.io/) and click on **Add a Cluster Now** button to start your free trial.

2.  Then choose your cloud provider. In this example, we will use AWS.

3.  Configure Access to AWS. On the next screen, you need to configure our provider. You need to provide AWS Access Key ID and Secret Access Key and optionally your SSH Key.

4.  If you don’t know where to find them, follow the instructions [here](https://stackpointcloud.com/community/tutorial/how-to-create-auth-credentials-on-amazon-web-services-aws) to create your user.

5.  Click on **Add Credentials** button.

6.  After you add your credentials, click on **Submit**.

## Create a Kubernetes Cluster
1.  On “Configure your provider” page click the edit button on Distribution and choose **Ubuntu 16.04 LTS**.

2.  Change the Cluster Name something meaningful like **OpenEBS Workshop**.

3.  You can leave all other option as default. Now click on **Submit** to create your cluster. This should take around 5-8 minutes to bring up one Master and two Workers Kubernetes Cluster.

## Import Kubernetes Stable OpenEBS Helm Charts
1.  Click on Solutions tab on the top of the screen and select **Import Charts** from the upper left.

Add the chart repo with the following details:
– name : openebs-charts
– type : Github
– repo url : https://github.com/openebs/openebs/k8s/charts/openebs

2.  Click on **Review Repository**.

3.  Make sure Access Verified shows ok and click on **Save Repository** button to finish adding chart repo.

## Add OpenEBS to Your Kubernetes Cluster
1.  First, make sure your cluster and all nodes are up.

2.  On the Control Plane tab click on your cluster name OpenEBS Workshop.

3.  Once the Kubernetes cluster is up on AWS with functional Helm, click on the **Solutions** tab and **Add Solution** button.

4.  Add the solution with the following details:

– namespace : default

5.  Click on **Install** to finally add OpenEBS into your cluster.

6.  State field should be green after OpenEBS is successfully added.

7.  Now your cluster is ready; you can run your workloads on openebs-standard storage class.

8.  To confirm, click on **Kubernetes Dashboard**. This will bring up your Kubernetes Dashboard UI in a new window. You should be able to find the openebs-standard option under Storage Classes.

Now you have your Kubernetes cluster up and running.
   
## Clone the lab repo

1.  Note your Kubernetes Master's Public IP and ssh into node.

2.  Once you are on the master node, from your command line, run:
   
```bash   
git clone https://github.com/openebs/workshop

cd openebs/workshop
```

This is the working directory for the workshop. You use the example `.yaml` files that are located in the _workshop/plans_ directory in the following exercises.

### [Continue to Exercise 1 - Accessing and validating your Kubernetes cluster](../exercise-1/README.md)
