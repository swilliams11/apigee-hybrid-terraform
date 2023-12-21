CWD=$1
MODULE=$2
KEY_FILE=$3

echo $CWD
echo $MODULE

echo "Uploading files to VM"
gcloud compute scp ~/$KEY_FILE apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/update_storage_class.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/storageclass.yaml apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/2_3_download_helm_charts.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a