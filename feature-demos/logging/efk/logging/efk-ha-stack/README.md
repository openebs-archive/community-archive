# EFK HA SETUP

* The contents of this directory is taken from https://github.com/pires/kubernetes-elasticsearch-cluster 
* I really appreciate the work of pires which has already saved a lot of time and work.
* I have tested this on GKE.
* The prerequisits given below is the minimum hardware requirement, Please refer to the link given above for more details.
* As this is just an demo setup, so i'm using emptydir, you should use any persistent storage such as openebs.

## Prerequisits :

- Min 3 nodes with min 8 cpu and 20 gb storage.

## How to deploy :
**Note** : Please run the following in the order

- Run `git clone https://github.com/openebs/community.git`
- change directory to `logging/efk-ha-setup/`
- Run `kubectl create ns logging`
- Run `kubectl create -f es-discovery-svc.yaml`
- Run `kubectl create -f es-svc.yaml`
- Run `kubectl create -f es-master.yaml`
- Run `kubectl rollout status -f es-master.yaml`
- Run `kubectl create -f es-client.yaml`
- Run `kubectl rollout status -f es-client.yaml`
- Run `kubectl create -f es-data.yaml`
- Run `kubectl rollout status -f es-data.yaml`
- Run `kubectl create -f fluentd-config.yaml`
- Run `kubectl create -f fluentd.yaml`
- Run `kubectl create -f kibana.yaml`
- Wait for atleast 5-10 mins to let the whole setup configured properly.
- Run `kubectl get svc -n=logging` and note down the NodePort (30560) and open
  the kibana UI in browser. (NodeIP:NodePort)
- Run `kubectl create -f openebs-operator.yaml`
- Open the discover tab in kibana ui and type `logstash-*` in the index-pattern 
- field and then choose `@timestamp` and click `create index pattern`.
- Now click on the `logstash-*` in the index pattern and then on discover tab, you
  should be able to get the logs there.
   
