---
title: WASM Plugin
subtitle:
description: Use wasm to expand Istio governance capabilities
author: solarmesh
keywords: [wasm]
---

##Why istio uses WASM

#### Through the implementation of WASM, we can get:

* Agility - wasm can dynamically load business logic into a running Envoy process without stopping or recompiling.

* Maintainability - We don't have to change Envoy's codebase to extend its functionality.

* Variety - Popular programming languages like C/C++ and Rust can compile to WASM, so developers can implement filters using the programming language of their choice.

* Reliability and isolation - The filter is deployed into a VM (sandbox) and therefore isolated from the hosting Envoy process itself (e.g. when a WASM filter crashes, it does not affect the Envoy process).

* Security - Because filters communicate with the host (Envoy proxy) through a well-defined API, they have access to and can only modify a limited number of connection or request properties.

#### It also has some disadvantages to consider:

* Performance is about 70% of native C++
* Memory usage will become higher due to the need to start one or more WASM virtual machines

### envoy proxy WASM SDK

Envoy Proxy runs WASM filters in a stack-based virtual machine, so the filter's memory is isolated from the host environment. All interactions between the embedded host (Envoy Proxy) and WASM filters are implemented through functions and callbacks provided by the Envoy Proxy WASM SDK.

WASM SDK supports implementation in multiple programming languages, such as:

*C++
*rust
* AssemblyScript
* Go

In this article, we will discuss how to write WASM filters for Envoy using the Go Envoy Proxy WASM SDK. We are not going to discuss the API of the Envoy Proxy WASM SDK in detail as it is beyond the scope of this article. However, we will cover some of the things necessary to master the basics of writing WASM filters for Envoy.
Our filter implementation must derive from the following two classes:
When the WASM plugin (the WASM binary containing the filter) is loaded, a root context is created. The root context has the same lifecycle as the VM instance, it executes our filters and is used to:

```go

type rootContext struct {
// You'd better embed the default root context
// so that you don't need to reimplement all the methods by yourself.
proxywasm.DefaultRootContext
}

type httpHeaders struct {
// we must embed the default context so that you need not to reimplement all the methods by yourself
proxywasm.DefaultHttpContext
contextID uint32
}
```

1. Initialize the wasm project

```bash
$ solarctl wasm init demo
  buildVersion = unknown, buildGitRevision = unknown, buildStatus = unknown, buildTag = unknown, buildHub = unknown
Use the arrow keys to navigate: ↓ ↑ → ←
? What language do you wish to use for the filter:
   ▸ cpp
     rust
     assemblyscript
     tinygo

```

The project structure is as follows:

```tree
demo
|-- go.mod
|-- main.go
|-- runtime-config.json
```

2. We add the code we need in the code. For example:
   Add a key="hello" value="world" to the http header
```go
// Override DefaultHttpContext.
func (ctx *httpHeaders) OnHttpResponseHeaders(numHeaders int, endOfStream bool) types.Action {
if err := proxywasm.SetHttpResponseHeader("hello", "world"); err != nil {
proxywasm.LogCriticalf("failed to set response header: %v", err)
}
return types.ActionContinue
}
```

3. Compile demo project

When building wasm using go language, you need to install tinygo

macos

```bash
brew install tinygo
```

After the installation is complete, execute in the root directory of the current project:

```bash
tinygo build -o filter.wasm -target=wasi -wasm-abi=generic .
```

`filter.wasm` will be generated after executing the current command

4. Upload the prepared wasm to a file server that can be accessed by the cluster

```bash
$ kubectl get po -n demo

NAME READY STATUS RESTARTS AGE
details-v1-5588477696-2sw7b 2/2 Running 0 8d
productpage-v1-5bd6875444-j75dp 2/2 Running 0 8d
ratings-v1-c9d5c65fc-l65mq 2/2 Running 0 8d
reviews-v2-c789c7bdc-tsg7q 2/2 Running 0 8d
reviews-v3-78944b866f-96nbw 2/2 Running 0 8d
```



5. Create envoyfilter

```yaml
kubectl apply -f-<<EOF
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
   name: basic-auth
   namespace: istio-system
spec:
   configPatches:
   - applyTo: HTTP_FILTER
     match:
       context: GATEWAY
       listener:
         filterChain:
           filter:
             name: envoy.http_connection_manager
       proxy:
         proxyVersion: ^1\.9.*
     patch:
       operation: INSERT_BEFORE
       value:
         name: istio.auth
         config_discovery:
           config_source:
             ads: {}
             initial_fetch_timeout: 0s # wait indefinitely to prevent bad Wasm fetch
           type_urls: [ "type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm"]
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
   name: auth-config
   namespace: istio-system
spec:
   configPatches:
   - applyTo: EXTENSION_CONFIG
     match:
       context: GATEWAY
     patch:
       operation: ADD
       value:
         name: istio.auth
         typed_config:
           '@type': type.googleapis.com/udpa.type.v1.TypedStruct
           type_url: type.googleapis.com/envoy.extensions.filters.http.wasm.v3.Wasm
           value:
             config:
               configuration:
                 '@type': type.googleapis.com/google.protobuf.StringValue
                 value: |
                   {
                     "basic_auth_rules": [
                       {
                         "prefix": "/productpage",
                         "request_methods":[ "GET", "POST" ],
                         "credentials":[ "ok:test", "YWRtaW4zOmFkbWluMw==" ]
                       }
                     ]
                   }
               vm_config:
                 vm_id: auth
                 code:
                   remote:
                     http_uri:
                     #wasmaddress
                       uri: http://release.solarmesh.cn/wasm/auth.wasm
                 runtime: envoy.wasm.runtime.v8

EOF
```

1. Send some traffic to HTTP port 8080 on the productpage service:

```bash
~ curl -L -v http://${GATEWAY}:9080
```

In the response we would like to see the filter's headers added to the response headers:

```yaml
     * About to connect() to frontpage.backyards-demo port 8080 (#0)
     * Trying 10.10.178.38...
     * Adding handle: conn: 0x10eadbd8
