#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <router_ip> <listen_port> <service_vip> <service_port>" >&2
  exit 1
fi

ROUTER_IP=$1
LISTEN_PORT=$2
SERVICE_VIP=$3
SERVICE_PORT=$4

iptables -t nat -C PREROUTING -d "${ROUTER_IP}/32" -p tcp --dport "${LISTEN_PORT}" \
  -j DNAT --to-destination "${SERVICE_VIP}:${SERVICE_PORT}" 2>/dev/null || \
iptables -t nat -A PREROUTING -d "${ROUTER_IP}/32" -p tcp --dport "${LISTEN_PORT}" \
  -j DNAT --to-destination "${SERVICE_VIP}:${SERVICE_PORT}"

iptables -t nat -C OUTPUT -d "${ROUTER_IP}/32" -p tcp --dport "${LISTEN_PORT}" \
  -j DNAT --to-destination "${SERVICE_VIP}:${SERVICE_PORT}" 2>/dev/null || \
iptables -t nat -A OUTPUT -d "${ROUTER_IP}/32" -p tcp --dport "${LISTEN_PORT}" \
  -j DNAT --to-destination "${SERVICE_VIP}:${SERVICE_PORT}"

iptables -t nat -C POSTROUTING -d "${SERVICE_VIP}/32" -p tcp --dport "${SERVICE_PORT}" \
  -j SNAT --to-source "${ROUTER_IP}" 2>/dev/null || \
iptables -t nat -A POSTROUTING -d "${SERVICE_VIP}/32" -p tcp --dport "${SERVICE_PORT}" \
  -j SNAT --to-source "${ROUTER_IP}"

echo "Published ${ROUTER_IP}:${LISTEN_PORT} -> ${SERVICE_VIP}:${SERVICE_PORT}"

