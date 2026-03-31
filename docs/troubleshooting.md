# Troubleshooting

## BGP Session Checks

On the router:

```bash
vtysh -c "show bgp summary"
vtysh -c "show running-config"
ip route
```

On a Cilium node:

```bash
kubectl -n kube-system exec ds/cilium -- cilium status --verbose
```

If sessions are not established:

- verify peer IP reachability
- verify ASN values
- check TCP/179 filtering
- confirm each node is selected by the peering policy

## LoadBalancer IP Allocation

```bash
kubectl get ciliumloadbalancerippools
kubectl get svc -A -o wide
```

If a service has no external IP:

- verify the pool exists
- verify the service is `type: LoadBalancer`
- verify pool selectors or annotations if you use them

## Service Advertisement

```bash
kubectl get ciliumbgppeeringpolicies -o yaml
kubectl get svc -A -o wide
```

If the route is missing on the router:

- confirm the policy advertises `LoadBalancerIP`
- confirm the service received a VIP
- confirm the BGP session is up on the node side and router side

## Gateway API

```bash
kubectl get gateway,httproute -A
kubectl describe gateway -A
kubectl describe httproute -A
```

If the gateway IP is not reachable:

- check that the gateway got an address
- check that the address belongs to a valid pool
- confirm the route exists on the edge router

## Edge NAT

```bash
iptables -t nat -S
iptables -S
curl -I http://<router-ip>:<published-port>/
curl -I http://<service-vip>/
```

If the raw VIP works but the router-local port does not:

- check `PREROUTING` DNAT
- check `OUTPUT` DNAT for local testing
- check `POSTROUTING` SNAT or `MASQUERADE`
- check `FORWARD` policy and accept rules

