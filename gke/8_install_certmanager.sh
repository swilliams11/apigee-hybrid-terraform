# /bin/sh

# install the cert manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.1/cert-manager.yaml

echo `kubectl get all -n cert-manager -o wide`
