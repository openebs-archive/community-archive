# Exercise 6 - Monitoring OpenEBS using Prometheus and Grafana

This is an optional exercise which will be useful if you need to track storage metrics on your OpenEBS volume. We recommended using the monitoring framework to track your OpenEBS volume metrics.

Prometheus can be installed as a microservice by the OpenEBS operator during the initial setup. Prometheus monitoring for a given volume is controlled by a volume policy. With granular volume, disk-pool, and disk statistics, the Prometheus and Grafana tool combination will empower the OpenEBS user community immensely in persistent data monitoring.

If you don't have an instance of Prometheus deployed, you can use the OpenEBS example to deploy Prometheus in your cluster.

OpenEBS uses Prometheus to monitor Volumes. OpenEBS use node-exporter to gather nodes metrics, cadviser for container metrics and maya-agent to gather OpenEBS volume's metrics.

## Launch Prometheus Operator
1.  Create configmap and launch prometheus-operator on your Kubernetes cluster.

    ```
    cd ~/openebs/k8s/openebs-monitoring/
    kubectl create -f configs/prometheus-config.yaml
    kubectl create -f configs/prometheus-env.yaml
    kubectl create -f configs/prometheus-alert-rules.yaml
    kubectl create -f configs/alertmanager-templates.yaml
    kubectl create -f configs/alertmanager-config.yaml
    kubectl create -f prometheus-operator.yaml
    kubectl create -f alertmanager.yaml
    kubectl create -f grafana-operator.yaml
    ```
    
2.  Verify the output. After successfully running the above commands, the output displayed is similar to the following :

    ```
    configmap "prometheus-config" created
    configmap "prometheus-env" created
    configmap "prometheus-alert-rules" created
    configmap "alertmanager-templates" created
    configmap "alertmanager-config" created
    
    serviceaccount "prometheus" created
    clusterrole "prometheus" created
    clusterrolebinding "prometheus" created
    deployment "prometheus-deployment" created
    service "prometheus-service" created
    daemonset "node-exporter" created
    
    deployment "alertmanager" created
    service "alertmanager" created
    
    service "grafana" created
    deployment "grafana" created
    ```

## Launch Prometheus Expression Browser

If it is minikube of a local deployment follow the steps below:

1.  Run `kubectl cluster-info` to get the NodeIP. An output similar to below will be displayed:

    ```
    $ kubectl cluster-info
    Kubernetes master is running at https://172.23.1.130:6443
    Heapster is running at https://172.23.1.130:6443/api/v1/namespaces/kube-system/services/heapster/proxy
    KubeDNS is running at https://172.23.1.130:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    ```
    
2.  Open NodeIP:32514/targets in your browser and it will launch Prometheus expression browser.

If it is a public cloud deployment follow the steps below:

1.  Find out your pods name:

    ```
    $ kubectl get pods
    NAME                                     READY     STATUS    RESTARTS   AGE
    alertmanager-79fc4b59db-82zmr            1/1       Running   0          8m
    grafana-7688b94dc-lr578                  1/1       Running   0          5m
    node-exporter-6gtgx                      1/1       Running   0          5m
    node-exporter-btdp8                      1/1       Running   0          5m
    node-exporter-k5v6t                      1/1       Running   0          5m
    prometheus-deployment-78cd57c5d7-q4sbl   1/1       Running   0          5m

    ```

2.  Find out which node it is running on:

    ```
    kubectl describe pods prometheus-deployment-78cd57c5d7-q4sbl
    Name:           prometheus-deployment-78cd57c5d7-q4sbl
    Namespace:      default
    Node:           ip-172-23-1-163.us-west-2.compute.internal/172.23.1.163
    ...
    ```

3.  Find out the external IP of the node. Replace the node name with yours below and run the command:

    ```
    $ kubectl describe node ip-172-23-1-163.us-west-2.compute.internal
    ...
    Addresses:
      InternalIP:   172.23.1.163
      ExternalIP:   34.220.11.3
      InternalDNS:  ip-172-23-1-163.us-west-2.compute.internal
      Hostname:     172.23.1.163
    ...
    ```
    
4.   Open `ExternalIP:32514/targets` in your browser and it will launch Prometheus expression browser.

## Launch Grafana UI

1.  Get the list of services:

    ```
    $ kubectl get svc
    NAME                                                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
    alertmanager                                        NodePort    10.3.0.95    <none>        9093:31854/TCP      23m
    grafana                                             NodePort    10.3.0.139   <none>        3000:32515/TCP      20m
    kubernetes                                          ClusterIP   10.3.0.1     <none>        443/TCP             4h
    pgset                                               ClusterIP   None         <none>        5432/TCP            35s
    pgset-primary                                       ClusterIP   10.3.0.240   <none>        5432/TCP            35s
    pgset-replica                                       ClusterIP   10.3.0.103   <none>        5432/TCP            34s
    prometheus-service                                  NodePort    10.3.0.8     <none>        80:32514/TCP        20m
    pvc-fef02f54-7339-11e8-9f52-06731769042c-ctrl-svc   ClusterIP   10.3.0.127   <none>        3260/TCP,9501/TCP   25s

    ```
    
2.  Note down the NodePort, used to launch `grafana` User Interface and `alertmanager`.

3.  To launch Grafana open NodeIP:NodePort (NodePort of grafana service) in your browser. If your cluster is on a public cloud provide then `ExternalIP:32514/login`.

4.  Login using the credentials admin/admin.

5.  After login add your data source by putting IP address of Prometheus to import the dashboard. Name it `prometheus`, select `Promethues` as type, and click on "Save and test" button to validate your source.

6.  Click on "Import dashboard" option.

7.  Copy the content of [openebs-dashboard.json](https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-monitoring/openebs-dashboard.json) file from OpenEBS repository and paste it into JSON field.

8.  Now, you can monitor your OpenEBS volume metrics from Grafana dashboard.

## Launch Alertmanager UI
1.  To launch `alertmanager` open a browser page and go to NodeIP:NodePort (NodePort of alertmanager service).
   
### [Continue to Exercise 7 - Taking a snapshot of a Persistent Volume](../exercise-7)
