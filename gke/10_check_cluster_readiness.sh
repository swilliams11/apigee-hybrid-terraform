# /bin/sh

HOME=`pwd`
APIGEE_HELM_CHARTS_HOME=$HOME/$1

kubectl config current-context

# get the cluster creds if necessary
# gcloud container clusters get-credentials $CLUSTER_NAME \
# --region $CLUSTER_LOCATION \
# --project $PROJECT_ID

mkdir $APIGEE_HELM_CHARTS_HOME/cluster-check

cp ./apigee-k8s-cluster-ready-check.yaml $APIGEE_HELM_CHARTS_HOME/cluster-check

# check the cluster readiness and wait for the results
kubectl apply -f $APIGEE_HELM_CHARTS_HOME/cluster-check/apigee-k8s-cluster-ready-check.yaml

echo `kubectl get jobs apigee-k8s-cluster-ready-check`


kubectl delete -f $APIGEE_HELM_CHARTS_HOME/cluster-check/apigee-k8s-cluster-ready-check.yaml

