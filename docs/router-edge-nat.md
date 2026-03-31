# Router Edge NAT

## Purpose

Dynamic routing through BGP makes service VIPs reachable, but that does not always mean they should be directly exposed to end users. The router can front selected services with local listener ports and translate traffic toward the cluster VIPs.

## Typical Use Cases

- expose a service on a router IP instead of the raw VIP
- present multiple services from one edge address
- keep internal VIP ranges private
- standardize entrypoints for non-cluster clients

## Pattern

### DNAT

Traffic hitting the router on a chosen address and port is rewritten toward the `LoadBalancer` IP.

### SNAT or MASQUERADE

Return traffic is normalized so the flow stays symmetric and client replies do not bypass the edge router.

## Example

See [router/iptables/publish-service.sh](../router/iptables/publish-service.sh) for a reusable publishing helper and [router/iptables/example-rules.txt](../router/iptables/example-rules.txt) for concrete examples.

## Notes

- publish only services that really need edge access
- keep one mapping table in Git so port ownership stays clear
- prefer idempotent scripts over manual one-off commands
- save router rules persistently after changes
