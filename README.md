# apigee-hybrid-terraform
Apigee Hybrid Terraform Installation

This Terraform script will install Apigee Hybrid into your GKE cluster as non-production.

## GKE Non-prod Installation

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




