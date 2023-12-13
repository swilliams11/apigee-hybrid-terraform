# apigee-hybrid-terraform
Apigee Hybrid Terraform Installation

This Terraform script will perform the following:
* install a non-production setup of Apigee Hybrid 
* into your GKE cluster (in Google Cloud)

## GKE Non-prod Installation

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

3. Apply Terraform
```shell
terraform apply
```




