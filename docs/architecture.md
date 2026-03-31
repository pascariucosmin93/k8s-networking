# Architecture

## Goal

Provide stable north-south access to workloads running on a bare-metal Kubernetes cluster without relying on a cloud load balancer.

## Building Blocks

- Kubernetes nodes on a private subnet
- Cilium `1.16.x`
- kube-proxy replacement enabled
- Cilium BGP Control Plane enabled
- Cilium Gateway API enabled
- FRR on an upstream edge router
- `iptables` on the edge router for selective service publishing

## Traffic Patterns

### Pod CIDR advertisement

Each Kubernetes node advertises its Pod CIDR to the edge router. This gives the router a route toward pod networks without static route management per node.

### LoadBalancer advertisement

Cilium allocates VIPs from one or more `CiliumLoadBalancerIPPool` resources. Those VIPs are then advertised over BGP so the edge router knows how to reach them.

### Gateway API

Gateway VIPs behave like other `LoadBalancer` services from a routing perspective. The upstream router only needs a route to the VIP; Cilium handles the rest inside the cluster.

### Edge publishing

Some services are intentionally hidden behind a router-local IP and TCP port. This keeps the cluster VIP private while still making the workload reachable from user-facing networks.

## Why This Pattern Works Well

- no external cloud dependency
- deterministic service IPs
- straightforward troubleshooting
- easy extension to more workloads
- good fit for home lab and on-prem demonstrations

## Security Boundaries

- the router decides what is externally reachable
- the cluster decides which services get VIPs
- Gateway API limits which routes attach to the gateway
- network policies can restrict east-west traffic behind the gateway

