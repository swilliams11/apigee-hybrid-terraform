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

#### Create a new Serice Account
You must create a new SA that has the following permissions:
* kubernetes Engine Admin 
* Kubernetes Engine Cluster Admin
* Create Service Account
* Service Account Key Admin
* IAM Policy Binding Permission

Create a new SA JSON Key, download it and save it to your home directory. 


### Apply and override variables
```shell
terraform apply -var="ssh_user=user_id"

# The service account key file must be located in your home directory (linux based home dir)
terraform apply -var="ssh_user=user_id" -var="service_account_email=sa@g.com" -var="service_account_key_file=sa_key_file.json"
```


### Target GKE only
This will only install the GKE environment and leave Apigee disabled.

```shell
terraform apply -target=module.gke -var=ssh_user=ADMIN -var=service_account_email=SERVICE_ACCT -var=service_account_key_file=SA_KEY_FILE
```

#### Troubleshooting these steps
Sometimes the upload files to VM fails and in this case you need to taint the resource so that Terraform will execute it again with the following command. Then you can execute the command listed above again.

```shell
terraform taint module.gke.null_resource.upload_files_to_vm
```

## NOTICE
This is not an officially support Google Cloud product.


## Notes
### 1/2/2023 
I had to replace the create_service_account shell script to remove the read prompt commands because they will not work in Terraform. 
This file must replace the existing file and execute instead. 