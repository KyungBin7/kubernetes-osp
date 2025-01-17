helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.9.0
helm list --namespace kube-system
kubectl --namespace=kube-system get pods --selector="app.kubernetes.io/instance=csi-driver-nfs"

cat <<EOF> storageclass-configure.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: default
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: nfs.csi.k8s.io
parameters:
  server: storage.example.com
  share: /nfs
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
EOF

kubectl apply -f storageclass-configure.yaml
kubectl get sc,pv,pvc

systemctl disable --now firewalld
setenforce 0

cat <<EOF> blog-pod-pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pgdata
  labels:
    app: pgdata
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
EOF

kubectl create -f blog-pod-pvc.yaml

kubectl get pvc