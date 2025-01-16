#!/bin/bash

helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --namespace network-metallb --create-namespace

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

cat <<EOF> ippool.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: network-metallb
spec:
  addresses:
  - 192.168.10.240-192.168.10.250
  autoAssign: true
EOF

cat <<EOF> l2.yaml
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: network-metallb
spec:
  ipAddressPools:
  - first-pool
  nodeSelectors:
  - matchLabels:
      kubernetes.io/hostname: node1.example.com
EOF
kubectl apply -f ippool.yaml
kubectl apply -f l2.yaml
kubectl get -f ippool.yaml
kubectl get -f l2.yaml