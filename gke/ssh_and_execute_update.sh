# /bin/sh
# This shell script is for regional gke clusters. 

gcloud compute ssh apigee-k8s-cluster-bastion --zone=us-central1-a --command './update_storage_class.sh'