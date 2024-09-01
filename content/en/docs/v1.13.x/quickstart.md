---
title: Quick Start
weight: 900
description: Get SolarMesh up in less than 5 minutes!
---

SolarMesh servicemesh is an efficient visual microservice governance platform based on Istio and container technology,
providing application life cycle management, comprehensive traffic management and non-intrusive service governance solutions.
The cornerstone of SolarMesh is the service mesh theory, and the underlying architecture is based on kubernetes and istio
(istio is a highly configurable and powerful servicemesh implementation solution).

### What is ServiceMesh?

ServiceMesh, also translated as "service mesh", serves as the infrastructure layer for communication between services. A servicemesh is a dedicated infrastructure layer that handles communication between services. It is responsible for reliably delivering requests through complex service topologies that encompass modern cloud-native applications. In practice, service meshes are typically implemented through a set of lightweight network proxies that are deployed alongside the application without being aware of the application itself.

ServiceMesh is usually used to describe the microservice network of applications and the interaction between applications. It is an infrastructure layer. As the size and complexity of programs increase, service meshes become increasingly difficult to understand and manage. Its requirements include service discovery, load balancing, fault recovery, indicator collection, monitoring, and more complex operation and maintenance requirements, such as A/B testing, canary release, current limiting, access control, and end-to-end authentication.

If you explain what a service mesh is in one sentence, you can compare it to TCP/IP between applications or microservices, which is responsible for network calls, current limiting, circuit breaking, and monitoring between services. When writing applications, you generally do not need to care about the TCP/IP layer (such as RESTful applications through the HTTP protocol). When using a service grid, you do not need to care about the functions between services that are originally implemented through applications and frameworks, such as Spring Cloud and OSS. , now it’s just a matter of handing it over to the service mesh.

### Characteristics of ServiceMesh

The servicemesh has the following characteristics:

* Middle layer for inter-application communication
  *Lightweight network proxy
  *Application-agnostic
* Decouple application retries, timeouts, monitoring, tracing and service discovery

### What does the ServiceMesh bring us?

From the perspective of the general trend of cloud native, the core point of cloud native lies in abstraction. Just as virtual machines were once abstracted from physical machines, the essence of cloud-native applications is to abstract all infrastructure from the independent applications themselves to form middleware-level tools, such as networks.

The entire abstraction of the network layer allows us to carry out standardized and unified management, thereby deriving the means of solving problems at the network layer. This abstraction at the network level eliminates the need for us to resort to SDK means (such as Spring Cloud) to solve problems due to network insufficiency. For problems arising from stability (timeouts, retries, etc.), the SDK has a certain binding relationship with the language. In today's era of microservices where multiple languages coexist, the capabilities provided by the SDK are slightly insufficient.

The emergence of servicemesh is to solve this problem, abstract the Kubernetes network, and provide language-independent enhancement methods. It is the middleware to solve Kubernetes network problems.

## Quick experience

Click [>>Online demo experience address>>](http://demo.solarmesh.cn/) to use it quickly~

## learn more?

Click on the link below to learn more about SolarMesh related features:

- [AI Plugins](/docs/v1.13.x/tutorials/wasmplugin/)
- [Canary Release](/docs/v1.13.x/tutorials/canary/)
- [Local rateLimit](/docs/v1.13.x/tutorials/ratelimit/)
- [Black and White List](/docs/v1.13.x/tutorials/ap/)
- [Traffic Plugin](/docs/v1.13.x/tutorials/mirror/)
- [Fault Injection](/docs/v1.13.x/tutorials/fault/)
- [Traffic Mirror](/docs/v1.13.x/tutorials/mirror/)
