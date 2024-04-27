---
title: Istio安装
subtitle:
description: 安装istio方式
author: solarmesh
keywords: [istio]
---

由于官方istio的镜像包所属docker.io，下载的时候可能会有限制，所以我们维护了 istio 1.13.9 版本的istio官方镜像，方便进行安装测试。

## 下载 solarmesh 安装包

> 如已经有安装包，省略以下步骤

```shell
wget http://release.solarmesh.cn/solar/v1.13/solar-v1.13.1-linux-amd64.tar.gz
tar -xvf solar-v1.13.1-linux-amd64.tar.gz
export PATH=$PATH:$PWD/solar/bin/
chmod +x $PWD/solar/bin/istioctl
```

## 安装istio
初始化 IstioOperator
```shell
istioctl operator init --hub registry.cn-shenzhen.aliyuncs.com/solarmesh --tag 1.13.9
```

安装 istio。

> 注意里面的注释。

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
    global:  ## 注意：以下配置在安装solarmesh的时候也会出现
      meshID: mesh01 # 定义网格名称
      multiCluster:
        clusterName: cluster01 # 定义集群名称
      network: network1 # 定义网络名称
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
                protocol: TCP
                targetPort: 8443
              - name: tcp
                port: 31400
                protocol: TCP
                targetPort: 31400
              - name: tls
                port: 15443
                protocol: TCP
                targetPort: 15443
              - name: promethues ## 以下是支撑 solarmesh的配置
                port: 9090
                protocol: TCP
                targetPort: 9090
              - name: kiali
                port: 20001
                protocol: TCP
                targetPort: 20001
              - name: networking-agent
                port: 7575
                protocol: TCP
                targetPort: 7575
              - name: grafana
                port: 3000
                protocol: TCP
                targetPort: 3000
              - name: jaeger
                port: 16686
                protocol: TCP
                targetPort: 16686
EOF
```

## 验证

```shell
$ kubectl get po -n istio-system
NAME                                   READY   STATUS    RESTARTS   AGE
istio-egressgateway-76766bdd95-s7vrb   1/1     Running   0          25s
istio-ingressgateway-bdf95b49b-xtc8r   1/1     Running   0          25s
istiod-7c79849787-g74gn                1/1     Running   0          54s
$ kubectl get po -n istio-operator
NAME                              READY   STATUS    RESTARTS   AGE
istio-operator-6b78df4f7c-gpmn8   1/1     Running   0          2m29s
```
