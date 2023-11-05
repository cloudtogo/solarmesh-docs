---
title: Black and White List
subtitle:
description: Zero Trust Security
author: solarmesh
keywords: [security]
---

Zero trust means there is no implicit trust, either inside or outside the network perimeter. SolarMesh is one of the important implementation carriers of cloud-native zero-trust system.
Integrating authentication and authorization from application code into SolarMesh makes it out-of-the-box, dynamically configurable, and updating policies is easier and takes effect immediately. This article introduces the use of SolarMesh to implement black and white list access for services.

**Preconditions:**

- Deploy the bookinfo project and inject sidecar into each instance.
- Deploy sleep service to facilitate testing

```sh
$ kubectl get po -n test -owide
NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
details-v1-65b994c875-kgbp2      2/2     Running   0          9d    10.36.0.9    49-node1   <none>           <none>
productpage-v1-8bf7687-nxb5t     2/2     Running   0          9d    10.36.0.14   49-node1   <none>           <none>
ratings-v1-bcdd8c995-vfqj9       2/2     Running   0          9d    10.36.0.16   49-node1   <none>           <none>
reviews-v1-5f4866bd47-sxr6b      2/2     Running   0          9d    10.36.0.17   49-node1   <none>           <none>
reviews-v2-7b66cff677-kjl4v      2/2     Running   0          9d    10.44.0.7    46-node2   <none>           <none>
reviews-v3-6dddcfbb87-94zkd      2/2     Running   0          9d    10.44.0.9    46-node2   <none>           <none>
sleep-5c88f5b48d-tlmb5           2/2     Running   0          9d    10.36.0.18   49-node1   <none>           <none>
```

Let us first remember that the IP of sleep-5c88f5b48d-tlmb5 is ``10.36.0.18``. Later, we will set that only this IP cannot access our productpage-v1-8bf7687-nxb5t, simulating a blacklist scenario.

## Try it

We first visit productpage-v1-8bf7687-nxb5t in `sleep-5c88f5b48d-tlmb5`:

```sh
$ kubectl exec -it sleep-5c88f5b48d-tlmb5 -n test sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
/$ curl -v productpage:9080
* Trying 10.21.152.27:9080...
* Connected to productpage (10.21.152.27) port 9080 (#0)
>GET/HTTP/1.1
> Host: productpage:9080
> User-Agent: curl/8.0.1-DEV
> Accept: */*
>
< HTTP/1.1 200 OK
< content-type: text/html; charset=utf-8
< content-length: 1683
< server: envoy
< date: Fri, 28 Apr 2023 09:33:56 GMT
< x-envoy-upstream-service-time: 149
<
<!DOCTYPE html>
<html>
   <head>
     <title>Simple Bookstore App</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
...
```

As you can see above the access is ok.

We now configure a blacklist to restrict its access.

![](img.png)

Save it and try accessing it again.

```sh
$ curl -v productpage:9080
* Trying 10.21.152.27:9080...
* Connected to productpage (10.21.152.27) port 9080 (#0)
>GET/HTTP/1.1
> Host: productpage:9080
> User-Agent: curl/8.0.1-DEV
> Accept: */*
>
< HTTP/1.1 403 Forbidden
< content-length: 19
< content-type: text/plain
< date: Fri, 28 Apr 2023 09:43:56 GMT
< server: envoy
< x-envoy-upstream-service-time: 71
<
* Connection #0 to host productpage left intact
```

The result shows 403, indicating that our configuration has taken effect.
