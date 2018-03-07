## Deploy efk-stack

- Run `kubectl create namespace logging`
- Run `kubectl create -f elasticsearch.yaml`
- Run `kubectl create -f fluentd-config.yaml`
- Run `kubectl create -f fluentd.yaml`
- Run `kubectl create -f kibana.yaml`

* After deploying all the three components, wait for atleast 5-6 minutes, till 
fluentd get configured completely, you may not be able to get the logs in kibana
untill its configured completely
* Run `kubectl get svc -n=logging` and note down the NodePort (30560) and open
the kibana UI in browser. (NodeIP:NodePort)
* Run `kubectl create -f openebs-operator.yaml`
* Open the discover tab in kibana ui and type `logstash-*` in the index-pattern 
field and then choose `@timestamp` and click `create index pattern`.
* Now click on the `logstash-*` in the index pattern and then on discover, you
should be able to get the logs there.

