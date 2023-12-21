# /bin/sh
# This shell script is for regional gke clusters. 
CLUSTER_NAME=$1
PROJECT_ID=$2
CLUSTER_LOCATION=$3
SA=$4
KEY_FILE=$5

gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./update_storage_class.sh $CLUSTER_NAME $PROJECT_ID $CLUSTER_LOCATION $SA $KEY_FILE"
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command './2_3_download_helm_charts.sh'
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command './4_create_service_accounts.sh'