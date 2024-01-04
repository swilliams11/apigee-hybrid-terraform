# /bin/sh
HOME=`pwd`
APIGEE_HELM_CHARTS_HOME=$HOME/$1

kubectl apply -k $APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/crds/default/ --server-side --force-conflicts --validate=false --dry-run=server

kubectl apply -k $APIGEE_HELM_CHARTS_HOME/apigee-operator/etc/crds/default/ --server-side --force-conflicts --validate=false

echo `kubectl get crds | grep apigee`