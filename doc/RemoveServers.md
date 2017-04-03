Remove Servers
------------------------

## Overview
This is a simple procedure that mimics a background process that would usually
monitor the state of backend servers and remove them from the pool once the sessions are drained.

## Remove steps
All steps performed from ASAPP/infrastructure directory.
- ansible-playbook -i hosts remove.yml --tags=go ; Remove the 1st server from the Go server pool
- ansible-playbook -i hosts remove.yml; Remove the 1st server from each server (go, py, lua) pool
