---
title: How to build a microservice management and control platform based on Istio
subtitle:
description:
date: 2023-01-24
author: solarmesh
keywords: [solarmesh microservice]
---

### What is Service Mesh?

Is a dedicated infrastructure layer that you add your application to. A service mesh provides centralized management for your cloud-native microservices architecture. This way you can optimize your application in terms of communication, routing, reliability, security, and observability.

### What challenges does microservice architecture face?

Comparison will be made with another application style (monolithic application). Monolithic applications typically have all business logic built-in, including ingress rules. When you move from a monolithic architecture to a microservices architecture, you end up with many smaller services. Each of these "micro" services performs an independent function of your application. Depending on the size of your monolithic application, the number of microservices can be very large, sometimes reaching hundreds or thousands. Monolithic applications solve the problem of how traffic enters the application (North-South traffic). In contrast, microservices also compose or reuse functionality with each other (east-west traffic).

Without a service mesh, each microservice would need not only business logic but also connectivity logic. Connectivity challenges include how to discover and connect to other microservices, how to exchange and protect data, and how to monitor network activity. Additionally, microservices can be changed quickly without requiring a complete redeployment. They are often moved dynamically within a Kubernetes cluster. Your application might even be distributed across multiple clusters, availability zones, or regions for resiliency.

As a result, some of the biggest challenges in microservices architecture include:

- Track changes between applications, especially as the number of microservices grows.

- Enforce security and compliance standards across all services and clusters.

- Use consistent policies to control network traffic.

- Troubleshoot network errors.

Let's look at it without a service mesh. In addition to implementing business logic, each microservice must ensure that it can communicate with other microservices; secure communications; apply retry, failover, and transfer strategies; manipulate headers based on which microservice a request is sent to; capture metrics and logs ;The most important thing is to track changes in the microservice architecture. While you can manage these tasks across several microservices, the complexity increases as you add more microservices to your ecosystem.

### How does a service mesh solve these challenges?

A service mesh does not implement communication, security, metrics, and other layers for each microservice. To abstract service-to-service communication, service meshes use proxies. Agents, also known as sidecars, are deployed alongside your microservices. For example, a proxy can be a container in the same Kubernetes pod as your application. Proxies form the data plane of the service mesh. By intercepting every communication between microservices, you can control the flow of traffic. For example, you can create rules to forward, protect, or manipulate requests.

Configuration for each sidecar proxy includes traffic encryption, certificates, and routing rules. A service mesh specifies and applies proxy configuration across microservices. This way, you get consistent networking, security, and compliance across your entire microservices architecture. All proxies send network traffic metrics back to the control plane that you can access using the API. You can then determine the health of your service mesh.

What are the advantages of a service mesh?

- Separate business and network logic:

- Set policies once and apply them wherever you need them

- Ensure high availability and fault tolerance

- Easily scale your microservices architecture

- Monitor the health and performance of your service mesh

### What is SolarMesh?

Although the service grid has so many advantages, and until today many users have used the service grid in their own business systems, it is still too complicated for many common users to use and operate such a system. , in normal use, we may only need to do a grayscale release, which involves the configuration of different rules, which is very error-prone. How to define the VirtualService, DestinationRule and other rules of the application requires a lot of effort for most users. High learning costs. In order to reduce the cost of use and difficulty of operation and maintenance, SolarMesh has launched the service grid capabilities through a high degree of productization capabilities. You only need to operate the console according to common ideas, and you can easily complete such as grayscale release. , fault injection, fuse current limiting and other capabilities.

What is SolarMesh? SolarMesh is a microservice supervision platform built on service grid. Based on Istio and container technology, SolarMesh provides microservice traffic monitoring and management, and provides complete non-intrusive service governance solutions. In addition to providing basic capabilities such as Istio traffic management, it also provides multi-cluster management, monitoring and alarming, Wasm plug-ins, and registration. Center, virtual machine, interface traffic, access logs, Istio component canary upgrade and other capabilities help enterprises quickly locate problems in complex microservice scheduling and improve research and development efficiency.

### Features of Solarmesh

SolarMesh has the following four major features:

Lightweight: The component includes 1 service on the control end and 1 service on the business end, with low resource usage and simple maintenance.

Intuitive: intuitively control single cluster and multi-cluster service status through traffic view

Convenient: easy to install (solarctl), easy to configure Istio rules, easy to check the status of microservices

Specification: SolarMesh uses standard istio specification operation and supports multi-version istio access.

### What application scenarios does SolarMesh support?

1. Visual troubleshooting of cloud application failures

SolarMesh provides traffic views to reflect service observability. The traffic view page displays the topology of services and workloads within the grid and displays it through real-time network traffic, latency, throughput, and more. Coupled with the SolarMesh interface traffic capability, online faults can be pinpointed to the interface and faults can be quickly troubleshooted.

2. Traffic management

Through SolarMesh, configuration-based traffic management can be easily implemented: it separates traffic management from infrastructure management and provides many traffic management functions independent of application code, helping to simplify traffic as the deployment scale gradually expands. manage.

3. Business observability

SolarMesh makes it easy to achieve observability between services, detecting and fixing issues quickly and efficiently with powerful, reliable, and easy-to-use monitoring capabilities. SolarMesh provides comprehensive monitoring capabilities at the service, load, container, and interface levels to improve diagnosis efficiency.

4. Service security

Through SolarMesh, you can easily implement two-way TLS authentication between services: Two-way TLS authentication does not need to change the service code during the implementation process, and can provide a powerful role-based identity authentication mechanism for each service to achieve cross-cluster and cross-cloud interactions. operate.

### What are the basic functions of SolarMesh?

- Multi-cluster management
- Traffic management
- Interface traffic
  -Wasm
- virtual machine
- Registration Center
- Monitor alarms
  -…

[SolarMesh free trial address>>](https://www.cloudtogo.cn/product-SolarMesh)
