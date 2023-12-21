# apigee-hybrid-terraform
Apigee Hybrid Terraform Installation

This Terraform script will perform the following:
* install a non-production setup of Apigee Hybrid 
* into your GKE cluster (in Google Cloud)

## GKE Non-prod Installation

### What actions does Terraform Module execute?
This Terraform module effectively executes the steps listed in this [document](https://cloud.google.com/apigee/docs/hybrid/v1.11/precog-overview) using the Helm installation.


### Prerequisites
1. Install gcloud
2. Install [Helm](https://helm.sh/docs/) version 3.10 or higher. 


### Setup
1. Login to GCP and set your default project. 
```shell
export PROJECT_ID=YOUR_PROJECT
gcloud auth login
gcloud auth application-default login
gcloud config set project $PROJECT_ID
```

2. Initialize Terraform.
`terraform init`

3. Apply Terraform and enter 'yes'
```shell
terraform apply
```

#### Note
While the script is executing, the command line will prompt you to login to GCP so that it can update the GKE cluster with the storage class. Please complete this step so that the script executes successfully.   


### Apply and override variables
```shell
terraform apply -var="ssh_user=user_id"

# The service account key file must be located in your home directory (linux based home dir)
terraform apply -var="ssh_user=user_id" -var="service_account_email=sa@g.com" -var="service_account_key_file=sa_key_file.json"
```

## NOTICE
This is not an officially support Google Cloud product.
