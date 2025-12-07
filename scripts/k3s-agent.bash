#!/bin/bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.122.10 --token 12345" sh -s -

cat /var/lib/rancher/k3s/server/node-token



Set the KUBECONFIG env var like you would a path variable and it will merge all config files.

Example:

KUBECONFIG="~/.kube/config:/etc/rancher/k3s/k3s.yaml"

