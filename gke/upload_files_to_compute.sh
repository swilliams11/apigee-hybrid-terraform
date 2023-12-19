CWD=$1
MODULE=$2

echo $CWD
echo $MODULE

echo "Uploading files to VM"
gcloud compute scp $MODULE/update_storage_class.sh apigee-k8s-cluster-bastion:~ --zone=us-central1-a
gcloud compute scp $MODULE/storageclass.yaml apigee-k8s-cluster-bastion:~ --zone=us-central1-a