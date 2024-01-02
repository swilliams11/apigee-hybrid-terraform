# /bin/sh
# This shell script is for regional gke clusters. 
CLUSTER_NAME=$1
PROJECT_ID=$2
CLUSTER_LOCATION=$3
SA=$4
KEY_FILE=$5
APIGEE_HELM_CHARTS_HOME=$6

echo "Updating the storage class..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./update_storage_class.sh $CLUSTER_NAME $PROJECT_ID $CLUSTER_LOCATION $SA $KEY_FILE"
echo "Downloading the Helm charts..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command './2_3_download_helm_charts.sh'
echo "Creating the service accounts..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./4_create_service_accounts.sh $APIGEE_HELM_CHARTS_HOME"
echo "Creating the TLS certs..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./5_create_tls_certs.sh $APIGEE_HELM_CHARTS_HOME"
echo "Creating the overrides..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./6_overrides.sh $APIGEE_HELM_CHARTS_HOME"