# /bin/sh
# This shell script is for regional gke clusters. 
CLUSTER_NAME=$1
PROJECT_ID=$2
CLUSTER_LOCATION=$3
SA=$4
KEY_FILE=$5
APIGEE_HELM_CHARTS_HOME=$6
APIGEE_ENV_GROUP_NAME=$7
APIGEE_ENV_NAME=$8
SSH_USER=$9

echo "Changing shell script permissions to execute..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command 'chmod 744 ./*.sh'
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
echo "enable synchronizer..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./7_enable_synchronizer_access.sh $PROJECT_ID $SSH_USER"
echo "install cert manager..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./8_install_certmanager.sh"
echo "install CRDS..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./9_install_crds.sh $APIGEE_HELM_CHARTS_HOME"
echo "check cluster readiness..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./10_check_cluster_readiness.sh $APIGEE_HELM_CHARTS_HOME"
echo "install apigee with helm..."
gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command "./11_install_apigee_with_helm.sh $APIGEE_HELM_CHARTS_HOME $PROJECT_ID $APIGEE_ENV_GROUP_NAME $APIGEE_ENV_NAME"