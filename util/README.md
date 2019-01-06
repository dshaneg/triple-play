# Utilities

## Curl Pod

When testing a service that only exposes a ClusterIP, it's handy to have a spy running inside the cluster to play with it. Deploy curlpod.yaml with

```sh
kubectl create -f util/curlpod.yaml
```

and then execute against the service endpoint with kubectl exec.

```sh
# get the cluster-ip of your service by executing this line
# (also, just replace $(id -un) with your username--you can probably type it quicker)
kubectl get services double-tap-local-$(id -un)-service

kubectl exec -it curl curl http://{cluster-ip-of-your-service}

kubectl get services double-tap-local-$(id -un)-service -o jsonpath='{spec.clusterIP}'

# ...or if you're copy/pasting anyway, just do this
# (played with an xargs version but couldn't get it to not show the download progress)
clusterip=$(kubectl get services double-tap-local-$(id -un)-service -o jsonpath='{.spec.clusterIP}') && kubectl exec -it curl curl ${clusterip}
```

Alternatively, you can use port forwarding instead of creating a spy pod.

```sh
kubectl port-forward deploy/double-tap-local-$(id -un) 8001:80
```

Then you can access the service from localhost.

```sh
curl localhost:8001
```

## Prod Namespace

Because this is a POC, I'm letting this one slide. Setting up namespaces should be part of the cluster deployment code.
However, this is the first time I've needed this namespace, so the code went here. To deploy it, just execute the following command.

```sh
kubectl create -f util/prod-ns.yaml
```
