## STEPS USED IN THE DEMO

- Create GKE cluster using the terraform templates
- Create grafana deployment using OpenEBS PV
- Login to grafana as admin, create some users 
- Kill the grafana application pod on Node-1 to schedule it on Node-2
- Verify if users are visible, create some users on Node-2
- Bring grafana back to Node-1 by killing the grafana pod 
- Verify if users created on Node-2 are visible
