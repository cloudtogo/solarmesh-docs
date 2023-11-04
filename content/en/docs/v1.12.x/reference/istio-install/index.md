---
title: Istio installation
subtitle:
description: How to install istio
author: solarmesh
keywords: [istio]
---

Since the official istio image package belongs to docker.io, there may be restrictions when downloading it, so we have maintained the istio 1.13.9 version of the istio official image to facilitate installation and testing.

## Download solarmesh installation package

> If you already have the installation package, omit the following steps

```shell
wget http://release.solarmesh.cn/solar/v1.12/solar-v1.12.1-linux-amd64.tar.gz
tar -xvf solar-v1.12.1-linux-amd64.tar.gz
export PATH=$PATH:$PWD/solar/bin/
chmod +x $PWD/solar/bin/istioctl
```

## Install istio
Initialize IstioOperator
```shell
istioctl operator init --hub registry.cn-shenzhen.aliyuncs.com/solarmesh --tag 1.13.9
```

Install istio.

> Pay attention to the comments inside.

```yaml
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
   namespace: istio-system
   name: demo
spec:
   hub: registry.cn-shenzhen.aliyuncs.com/solarmesh
   tag: 1.13.9
   profile: default
   meshConfig:
     accessLogFile: /dev/stdout
     enableTracing: true
     defaultConfig:
       proxyMetadata:
         ISTIO_META_DNS_CAPTURE: "true"
         ISTIO_META_DNS_AUTO_ALLOCATE: "true"
       extraStatTags:
         - request_path
         - request_method
   values:
     global: ## Note: The following configuration will also appear when installing solarmesh
       meshID: mesh01 # Define the mesh name
       multiCluster:
         clusterName: cluster01 #Define cluster name
       network: network1 # Define the network name
   components:
     pilot:
       k8s:
         env:
         - name: PILOT_TRACE_SAMPLING
           value: "100"
         - name: PILOT_FILTER_GATEWAY_CLUSTER_CONFIG
           value: "true"
         - name: PILOT_ENABLE_FLOW_CONTROL
           value: "true"
         resources:
           requests:
             cpu: 10m
             memory: 100Mi
     egressGateways:
     - name: istio-egressgateway
       enabled: true
       k8s:
         resources:
           requests:
             cpu: 10m
             memory: 40Mi
     ingressGateways:
       - name: istio-ingressgateway
         enabled: true
         k8s:
           service:
             ports:
               - name: status-port
                 port: 15021
                 protocol: TCP
                 targetPort: 15021
               - name: http2
                 port: 80
                 protocol: TCP
                 targetPort: 8080
               - name: https
                 port: 443
                 protocol:TCP
                 targetPort: 8443
               - name: tcp
                 port: 31400
                 protocol: TCP
                 targetPort: 31400
               - name: tls
                 port: 15443
                 protocol:TCP
                 targetPort: 15443
               - name: promethues ## The following is the configuration to support solarmesh
                 port: 9090
                 protocol: TCP
                 targetPort: 9090
               - name: kiali
                 port: 20001
                 protocol: TCP
                 targetPort: 20001
               - name: networking-agent
                 port: 7575
                 protocol:TCP
                 targetPort: 7575
               - name: grafana
                 port: 3000
                 protocol:TCP
                 targetPort: 3000
               - name: jaeger
                 port: 16686
                 protocol: TCP
                 targetPort: 16686
EOF
```

## verify

```shell
$ kubectl get po -n istio-system
NAME READY STATUS RESTARTS AGE
istio-egressgateway-76766bdd95-s7vrb 1/1 Running 0 25s
istio-ingressgateway-bdf95b49b-xtc8r 1/1 Running 0 25s
istiod-7c79849787-g74gn 1/1 Running 0 54s
$ kubectl get po -n istio-operator
NAME READY STATUS RESTARTS AGE
istio-operator-6b78df4f7c-gpmn8 1/1 Running 0 2m29s
```
