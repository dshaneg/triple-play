# Curl Pod

When testing a service that only exposes a ClusterIP, it's handy to have a spy running inside the cluster to play with it. Deploy curlpod.yaml with

```sh
kubectl create -f util/curlpod.yaml
```

and then execute against the service endpoint with kubectl exec

```sh
kubectl exec -it curl curl http://{cluster-ip-of-your-service}
```
