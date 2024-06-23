---
title: 安装
weight: 1000
description: SolarMesh安装说明.
---

## 前置条件

### 环境配置

在安装 SolarMesh 之前，请先查看以下环境要求：

1. 准备一个1.21 及以上版本Kubernetes环境，确保可以访问外网、确保可以正常拉取镜像、确保有一定的计算资源，可以跑较多的应用。
2. 准备 kubectl、helm工具

### 下载安装包

安装包中包含命令行工具和helm charts包。
```shell
# 下载
wget http://release.solarmesh.cn/solar/v1.12/solar-v1.12.1-linux-amd64.tar.gz
# 解压
tar -xvf solar-v1.12.1-linux-amd64.tar.gz
# 赋权
export PATH=$PATH:$PWD/solar/bin/
chmod +x $PWD/solar/bin/solarctl
chmod +x $PWD/solar/bin/istioctl
```

确认版本:
```shell
$ solarctl version
solarctl version: v1.12.1
```

## 安装 SolarMesh

### 安装istio

```shell
$ istioctl operator init --hub registry.cn-shenzhen.aliyuncs.com/solarmesh --tag 1.13.9

$ kubectl apply -f - <<EOF
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

验证：
````shell
$ kubectl get po -n istio-system
NAME                                   READY   STATUS    RESTARTS   AGE
istio-egressgateway-76766bdd95-s7vrb   1/1     Running   0          25s
istio-ingressgateway-bdf95b49b-xtc8r   1/1     Running   0          25s
istiod-7c79849787-g74gn                1/1     Running   0          54s
$ kubectl get po -n istio-operator
NAME                              READY   STATUS    RESTARTS   AGE
istio-operator-6b78df4f7c-gpmn8   1/1     Running   0          2m29s
````


### 1. 安装SolarMesh dashboard
```bash
solarctl install solar-mesh
```

检查组件状态：
```shell
$ kubectl get po -A -w
NAMESPACE              NAME                                               READY   STATUS    RESTARTS   AGE
service-mesh           solar-controller-58fc49b759-hpdwd                  2/2     Running   0          102s
service-mesh           solar-controller-58fc49b759-kwtf5                  2/2     Running   0          103s
solar-operator         solar-operator-596d9b48dc-knr7w                    1/1     Running   0          32s
```

配置登录账号：admin/admin
```shell
kubectl create secret generic admin --from-literal=username=admin --from-literal=password=admin -n service-mesh
kubectl label secret admin app=solar-controller -n service-mesh
```

### 2. 安装SolarMesh backend

#### 1. 控制器
```shell
export ISTIOD_REMOTE_EP=$(kubectl get nodes|awk '{print $1}' |awk 'NR==2'|xargs -n 1 kubectl get nodes  -o jsonpath='{.status.addresses[0].address}')
solarctl operator init --external-ip $ISTIOD_REMOTE_EP --eastwest-external-ip $ISTIOD_REMOTE_EP
```

#### 2. 后端服务
```shell
kubectl apply -f - <<EOF
apiVersion: install.solar.io/v1alpha1
kind: SolarOperator
metadata:
  name: cluster01 # 指定集群名称
  namespace: solar-operator
spec:
  profile: default
  istioVersion: "1.13"  ## 对应您Istio的安装版本
EOF
```

检查安装状态：

```shell
$ kubectl get po -n service-mesh
NAMESPACE              NAME                                               READY   STATUS    RESTARTS   AGE
service-mesh           networking-agent-d79988595-58tbs                   3/3     Running   0          52s
service-mesh           networking-agent-d79988595-nzfg5                   3/3     Running   0          2m46s
$ kubectl get po -n solar-operator
solar-operator         solar-operator-78d69dc876-sl7rl                    1/1     Running   0          7m20
```

#### 3. 安装Addons

1. 快速自定义功能。资源清单在安装包中，路径为：/solar/manifests/addon/
```shell
helm install kube-shortcut kube-shortcut -n kube-shortcut-system
kubectl apply -f kube-shortcut/files/solarmesh.yaml
```

2. 链路追踪和监控告警
```shell
$ solarctl install grafana --name cluster01
$ solarctl install jaeger --name cluster01
```

3. 安装prometheus、kiali

```shell
$ pwd
/root/solar/manifests/addon
$ helm install prometheus prometheus -n istio-system
$ helm install kiali kiali -n istio-system
```

检查安装状态：

```shell
$ kubectl get po -n kube-shortcut-system
NAME                                               READY   STATUS    RESTARTS   AGE
kube-shortcut-controller-manager-67d5d59f6-hq7nd   2/2     Running   0          2m39s

$ kubectl get po -n service-mesh
NAME                                READY   STATUS    RESTARTS   AGE
grafana-5d5ff44cd6-8wdj9            1/1     Running   0          1m
jaeger-5447b6ddcc-z4ng7             1/1     Running   0          1m

$ kubectl get po -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-658847747d-sqsjp    1/1     Running   0          39m
istio-ingressgateway-547c7d5bdf-brgrt   1/1     Running   0          39m
istiod-768bd77b6-spnrc                  1/1     Running   0          39m
kiali-d596b8bf4-hxp26                   1/1     Running   0          11m
prometheus-759d98874d-6wrnd             2/2     Running   0          14m
```

### 3. 完成集群初始化

注册集群kubeConfig到solarmesh
```shell
solarctl register --kube-config .kube/config --name cluster01
```

#### 4. 安装验证

访问 solarmesh dashboard, 使用如下命令获取 入口：
```shell
$ kubectl get svc -n service-mesh -l app=solar-controller
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
solar-controller   ClusterIP   10.96.202.179   <none>        8080/TCP   28m
```
访问：

![](img.png)

#### 5. 验证功能

使用 solarctl 安装 bookinfo示例项目到测试用的namespace当中

```shell
solarctl install bookinfo -n demo

$ kubectl get po -n demo
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-8d56bfc84-qj7n9        1/1     Running   0          9m42s
productpage-v1-7cbccd8fc4-b84qc   1/1     Running   0          9m42s
ratings-v1-585fc5fbdd-x2nkk       1/1     Running   0          9m42s
reviews-v1-dbbb74b84-ktn7j        1/1     Running   0          9m42s
reviews-v2-75c48c6c58-bjts2       1/1     Running   0          9m42s
reviews-v3-68cd99b996-5n29d       1/1     Running   0          9m42s
```

进入SolarMesh的Namespaces页面，打开自动接入的开关。

访问bookinfo的 productpage页面，查看 solarmesh 流量视图,证明SolarMesh现在已经安装成功了。

![](img_1.png)

## 高可用和水平扩展

### 提高可用性

默认SolarMesh 安装的 solar-controller 与 networking-agent 组件都是2个副本，在一般情况下已经能满足较高负载的请求。

一般情况下，组件服务所拥有副本数越多，所对应的可用容错能力也就越高。如果你对可用性要求很高，可以继续提高副本数以增强容错能力。

### 高可用部署
如果您熟练使用istio多集群的安装与配置，并需要solar-controller 支持多集群级别的高可用，我们的solar-controller 可以部署在istio多集群形态中，这是我们最终形态的SolarMesh高可用部署。

为了成功部署高可用，你需要参照以下的说明。

1. 首先你得准备一个istio的多集群，部署的模式为 [multi-primary](https://istio.io/latest/docs/setup/install/multicluster/multi-primary/) .

2. 在Istio部署的两个集群（假设名为 cluster1、cluster2）中分别执行 SolarMesh的管理集群 的安装。

3. 在Istio部署的cluster1、cluster2集群中配置 Istio 的 Gateway 与 VirtualService 资源，使流量可以通过网关配置的域名访问到 solar-controller 组件。后续你访问SolarMesh就使用你现在配置的域名。

如下cluster1的配置：你得保证你的域名是可访问的

```shell
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: gw
  namespace: service-mesh
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "web1.solarmesh.cn"

---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vs
  namespace: service-mesh
spec:
  hosts:
  - "*"
  gateways:
  - gw
  http:
  - route:
    - destination:
        host: solar-controller
        port:
          number: 8080
```

4. 测试。你访问 web1.solarmesh.cn ，然后查看 两个集群中的 solar-controller 对应的 pod 的日志。当你看到 日志是轮询产生的时候，说明 SolarMesh的管理集群 已经高可用部署成功了。

5. 安装SolarMesh的后端服务

6. 完成集群初始化，注册集群kubeConfig到solarmesh。注意，你需要在Istio安装的cluster1、cluster2中都执行注册业务集群的命令。

7. 其他。高可用部署 部署的模式下，目前 SolarMesh功能中通配策略 现在还无法高可用 ，你需要在Istio的cluster1、cluster2中都配置相应的策略。

## 了解更多

点击下面的链接，了解更多 SolarMesh 的相关功能：

- [灰度发布](/zh/docs/v1.12.x/tutorials/canary/)
- [本地限流](/zh/docs/v1.12.x/tutorials/ratelimit/)
- [黑白名单](/zh/docs/v1.12.x/tutorials/ap/)
- [流量插件](/zh/docs/v1.12.x/tutorials/mirror/)
- [故障注入](/zh/docs/v1.12.x/tutorials/fault/)
