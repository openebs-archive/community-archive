# Kubernetes does not have API Objects for User Accounts. Of the available ways
# to manage authentication is use of OpenSSL certificates for their simplicity. 
# refer: https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/

# The necessary steps are:

# Create a private key for your user. 
# In this example, we will name the file employee.key
openssl genrsa -out employee.key 2048

# Create a certificate sign request employee.csr using the private key you just 
# created (employee.key in this example). Make sure you specify your username and
# group in the -subj section (CN is for the username and O for the group).
openssl req -new -key employee.key -out employee.csr -subj "/CN=employee/O=openebs"

# Locate your Kubernetes cluster certificate authority (CA). 
# This will be responsible for approving the request and generating the 
# necessary certificate to access the cluster API. Its location is normally 
# /etc/kubernetes/pki/. In the case of Minikube, it would be ~/.minikube/. 
# Check that the files ca.crt and ca.key exist in the location.

# Generate the final certificate employee.crt by approving the certificate 
# sign request, i.e. employee.csr, you made earlier. In this example, the 
# certificate will be valid for 500 days
openssl x509 -req -in employee.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out employee.crt -days 500

# Save both employee.crt and employee.key in a safe location (in this example 
# we will use /home/employee/.certs/
rm -rf /home/employee/.certs

sudo mkdir -p /home/employee/.certs
sudo cp employee.crt /home/employee/.certs/
sudo cp employee.key /home/employee/.certs/

# create kubernetes user credentials to access kubernetes
kubectl config set-credentials employee --client-certificate=/home/employee/.certs/employee.crt  --client-key=/home/employee/.certs/employee.key

# Add a new context with the new credentials for your Kubernetes cluster. 
# This example is for a Minikube cluster
kubectl config set-context employee-context --cluster=minikube --namespace=apps --user=employee
