#!/usr/bin/env python3
import json
from enum import Enum

NB_WORKERS=3
WORKERS_GROUP="workers"
NB_CONTROL=3
CONTROL_GROUP="control"
GATEWAY_EXPOSED_IP="192.168.1.69"
GATEWAY_GROUP="gateway"
SSH_TUNNEL=f"-J ubuntu@{GATEWAY_EXPOSED_IP}"
SSH_TUNNEL_KEY="ansible_ssh_common_args"
POD_CIDR_TEMPLATE="10.64.%d.0/24"

POD_CIDR_LOWER_BOUND_WORKER=128
POD_CIDR_UPPER_BOUND_WORKER=255

POD_CIDR_LOWER_BOUND_CONTROL=0
POD_CIDR_UPPER_BOUND_CONTROL=127


class NodeType(Enum):
    CONTROL = { "lower": 0, "upper": 127 }
    WORKER = { "lower": 128, "upper": 255 }

hostvars=dict()

def get_pod_cidr(id: int, type: NodeType) -> str:
    lower = type.value['lower']
    upper = type.value['upper']
    pod_cidr_assigned_range = lower + id
    if pod_cidr_assigned_range > upper:
        raise Exception(f"Too many nodes of type {type.name} for the current limits. Cant assign pod cidr.")
    return POD_CIDR_TEMPLATE % pod_cidr_assigned_range


def generate_gateway_hosts() -> dict:
    gateway = dict()
    gateway["hosts"] = [ GATEWAY_EXPOSED_IP ]
    return gateway

def generate_workers_hosts() -> dict:
    global hostvars
    workers = dict()
    hosts = []
    for i in range(0, NB_WORKERS):
        hostname=f"worker{i}"
        vars=dict()
        hosts.append(hostname)
        vars["id"] = i
        vars["pod_cidr"] = get_pod_cidr(i, NodeType.WORKER)
        hostvars[hostname] = vars
    workers["hosts"] = hosts
    workers["vars"] = { SSH_TUNNEL_KEY: SSH_TUNNEL }
    return workers

def generate_control_hosts() -> dict:
    global hostvars
    control = dict()
    hosts = []
    for i in range(0, NB_CONTROL):
        hostname=f"control{i}"
        vars=dict()
        hosts.append(hostname)
        vars["id"] = i
        vars["pod_cidr"] = get_pod_cidr(i, NodeType.CONTROL)
        hostvars[hostname] = vars
    control["hosts"] = hosts
    control["vars"] = { SSH_TUNNEL_KEY: SSH_TUNNEL }
    return control

inventory = dict()
inventory["_meta"] = { "hostvars": hostvars }
inventory[GATEWAY_GROUP] = generate_gateway_hosts()
inventory[WORKERS_GROUP] = generate_workers_hosts()
inventory[CONTROL_GROUP] = generate_control_hosts()

print(json.dumps(inventory))