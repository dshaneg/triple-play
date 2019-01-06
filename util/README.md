# Utilities

## Curl Pod

When testing a service that only exposes a ClusterIP, it's handy to have a spy running inside the cluster to play with it. Deploy curlpod.yaml with

```sh
kubectl create -f util/curlpod.yaml
```

and then execute against the service endpoint with kubectl exec.

```sh
# get the cluster-ip of your service by executing
# also, just replace $(id -un) with your username--you can probably type it quicker
kubectl get services double-tap-local-$(id -un)
kubectl exec -it curl curl http://{cluster-ip-of-your-service}
```

Alternatively, you can use port forwarding instead of creating a spy pod.

```sh
kubectl port-forward deploy/double-tap-local-$(id -un) 8001:80
```

## Prod Namespace

Because this is a POC, I'm letting this one slide. Setting up namespaces should be part of the cluster deployment code.
However, this is the first time I've needed this namespace, so the code went here. To deploy it, just execute the following command.

```sh
kubectl create -f util/prod-ns.yaml
```
