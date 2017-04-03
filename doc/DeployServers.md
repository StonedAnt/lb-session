Deploy Servers
------------------------

## Overview
The main purpose of this demo is preserving users sessions during deployments, which means
the new release should start receiving new connections after the deployment, while the old release
should maintain existing connections until clients close them.

The proposed solution is using evaluation version of the latest Nginx Plus edition due to its excellent
capabilities for preserving connections when the configuration is reloaded dynamically.

In addition, Nginx Plus simplifies the dynamic management of pools through its API interface.

Normally the deployment procedure could involve a build step where the build artifacts are placed in some
kind of repository before they could be deployed in the target environments.

In this demo the build artifacts are zip archives that are part of the Ansible roles. They are simply uploaded to the target host.

Although, only a proof of concept, this solution could be used as a base for large deployments
which require complex deployments scenarios. One would probably consider in such cases using additional
technologies like etcd for distributed state management of the pools, confd for dynamic management of server configurations,
intelligent monitoring, etc.

## Deployment workflow
For demonstration purposes some assumptions were made as to the size of the pool and how many instances
of the backend servers could be active and drained in the pool. The drained state refers to the state of the
backend server when the instance is not receiving new connections.

In this demo the pool can have only two backend instances - one active and one in the drained state.
The drained instance should be removed manually, which mimics the procedure in a realistic scenario
where the drained instance is usually removed by some background monitoring process after certain criteria
is met.

The management of the pool performed with the help of Ansible roles. Ansible playbooks retrieve the information about
the pool state and manage its state through a bash script in the utils role: roles/util/files/manage_servers.sh
This script encapsulates the management of the pool through API calls.

For example the criteria could be a combination of certain metrics like number of active users sessions and/or
maximum allowed time for a server to be in a drained state.

The target host consists of one Ubuntu node. Each server type (Go, Lua, Python) maintains a different alias for this node
through /etc/hosts and the ansible inventory hosts file.

The deployment workflow consists of the following steps:
- Inspect the state of the Load Balancer pool.
- Deploy new build using the next available port in the poo.
- Activate the new backend server in the pool.
- Drain the server with the old build.

## Deployment example for an empty pool
All steps performed from ASAPP/infrastructure directory.
- ansible-playbook -i hosts deploy.yml --tags=go ; Pool state 1 active server
- ansible-playbook -i hosts deploy.yml --tags=go ; Pool state 1 active, and 1 drained server
- ansible-playbook -i hosts remove.yml --tags=go ; Pool state 1 active server; Drained server removed

## Deployment examples
All steps performed from ASAPP/infrastructure directory.
- Deploy all servers:
  ansible-playbook -i hosts deploy.yml
- Deploy only Go servers:
  ansible-playbook -i hosts deploy.yml --tags=go
- Deploy only Pythong, and Luas servers:
  ansible-playbook -i hosts deploy.yml --tags=py,lua
- List the target hosts for Python servers
  ansible-playbook -i hosts deploy.yml -l py_servers  --list-hosts
