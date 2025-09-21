#!/usr/bin/env python3
import json

NB_WORKERS=3
WORKERS_GROUP="workers"
NB_CONTROL=3
CONTROL_GROUP="control"
GATEWAY_EXPOSED_IP="192.168.1.69"
GATEWAY_GROUP="gateway"
SSH_TUNNEL=f"-J ubuntu@{GATEWAY_EXPOSED_IP}"
SSH_TUNNEL_KEY="ansible_ssh_common_args"

hostvars=dict()

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
        hostvars[hostname]=vars
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
        hostvars[hostname]=vars
    control["hosts"] = hosts
    control["vars"] = { SSH_TUNNEL_KEY: SSH_TUNNEL }
    return control

inventory = dict()
inventory[GATEWAY_GROUP] = generate_gateway_hosts()
inventory[WORKERS_GROUP] = generate_workers_hosts()
inventory[CONTROL_GROUP] = generate_control_hosts()
inventory["hostvars"] = hostvars

print(json.dumps(inventory))