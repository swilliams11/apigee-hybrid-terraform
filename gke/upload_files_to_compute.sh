CWD=$1
MODULE=$2
KEY_FILE=$3
SSH_USER=$4

echo $CWD
echo $MODULE

#gcloud config set account $SSH_USER
# this should be wrapped in a condition to check if valid credentials exists
echo `gcloud auth login`
echo "Uploading files to VM"
echo "executing...gcloud compute scp ~/$KEY_FILE apigee-k8s-cluster-bastion:~ --zone=us-central1-a"
gcloud compute scp ~/$KEY_FILE apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/apigee-k8s-cluster-ready-check.yaml apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/create-service-account apigee-k8s-cluster-bastion:~ --zone=us-central1-a
#gcloud compute scp $KEY_FILE apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/overrides.yaml apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/update_storage_class.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/storageclass.yaml apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/2_3_download_helm_charts.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/4_create_service_accounts.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/5_create_tls_certs.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/6_overrides.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/7_enable_synchronizer_access.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/8_install_certmanager.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/9_install_crds.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/10_check_cluster_readiness.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/11_install_apigee_with_helm.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a