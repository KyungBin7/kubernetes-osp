#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace network-ingress-nginx --create-namespace

helm list --namespace network-ingress-nginx
kubectl get pods -n network-ingress-nginx