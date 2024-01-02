variable "project_id" {
    type = string
}

variable "region" {
    type = string
    description = "GKE cluster region"
}

variable "ip_range_pods" {
    type = string
    description = "secondary IP CIDR block for GKE pods"
}

variable "ip_range_services" {
    type = string
    description = "secondary IP CIDR block for GKE services"
}

variable "name" {
    type = string
    description = "Clusters Name"
}

variable "network" {
    type = string
    description = "Name of the VPC network where the GKE cluster should be created."
}

variable "subnetwork" {
    type = string
    description = "Subnetwork within the VPC network where the GKE cluster will be created."
}

# variable "gke_creds"{
#     type = string
#     description = "GKE cluster credentials"
# }

variable "ssh_user" {
  type = string
  description = "The user name used to ssh into the bastion VM instance"
  sensitive = true
  nullable = false
}

variable "node_locations" {
    type = string
    default = "us-central1-a"
    #default = "us-central1-a,us-central1-b,us-central1-c"
}

variable "service_account_key_file" {
    type = string
    description = "The Google Cloud Service Account key (.json) file which is used to execute the kubectl commands on the bastion VM."
}

variable "service_account_email" {
    type = string
    description = "The Google Cloud Service Account email that is used to execute the kubectl commands on the bastion VM."
}

variable "subnet_id" {
    type = string
}

variable "subnet_range_name" {
    type = list(string)
}

variable "apigee_helm_charts_home" {
    type = string
    default = "apigee-hybrid/helm-charts"
    description = "Apigee Helm Charts home location on the bastion VM host."
}