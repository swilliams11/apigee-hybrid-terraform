# /bin/sh
# This shell script is for regional gke clusters. 

CLUSTER_NAME=cluster-1
PROJECT_ID=apigee-terraform-hybrid
CLUSTER_LOCATION=us-central1

# Update the storage class.
# https://cloud.google.com/apigee/docs/hybrid/v1.11/helm-install-create-cluster
echo "Fetching the cluster's credentials"

gcloud compute ssh "apigee-k8s-cluster-bastion" --zone=us-central1-a

echo "installing kubectl..."
sudo apt-get install kubectl -y
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
#gcloud components install kubectl --quiet

gcloud container clusters get-credentials cluster-1 --region us-central1 --project apigee-hybrid-terraform
#gcloud container clusters get-credentials cluster-1 --region

echo "Applying the storage class update..."
kubectl apply -f ./storageclass.yaml

echo "Patching the storage class..."
kubectl patch storageclass standard-rwo \
-p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

kubectl patch storageclass apigee-sc \
-p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Verify the results of the patch..."
# print the storage class
kubectl get sc

echo "Enabling the workload identity..."
# Enabled the workload identity
gcloud container clusters update ${CLUSTER_NAME} \
  --workload-pool=${PROJECT_ID}.svc.id.goog \
  --project ${PROJECT_ID} \
  --region ${CLUSTER_LOCATION}

echo "Verify the results of the workload identity..."
# Verify the identity is good to go
gcloud container clusters describe ${CLUSTER_NAME} \
--project ${PROJECT_ID} \
--region ${CLUSTER_LOCATION} | grep -i "workload"