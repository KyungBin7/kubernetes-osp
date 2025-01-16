#!/bin/bash

dnf install nfs-utils -y
systemctl enable --now nfs-server
mkdir -p /nfs/

cat <<EOF> /etc/exports.d/kubernetes.exports
/nfs *(rw,sync,no_root_squash,insecure,no_subtree_check,nohide)
EOF

systemctl enable --now nfs-server
exportfs -avrs
showmount -e storage.example.com
systemctl disable --now firewalld