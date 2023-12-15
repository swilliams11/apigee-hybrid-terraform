variable "gcp_service_list_gke" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "compute.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com"
  ]
}

variable "project_id" {
    type = string
    default = "apigee-hybrid-terraform"
}

variable "apigee_org_name" {
    type = string
    default = "apigee-hybrid-terraform"
}

variable "apigee_org_name_full_path" {
    type = string
    default = "organizations/apigee-hybrid-terraform"
}

variable "apigee_env_name" {
    type = string
    default = "hybrid-env"
}

variable "apigee_env_group_name" {
    type = string
    default = "hybrid-group"
}

variable "apigee_env_hostname" {
    type = string
    default = "delta.com"
}

variable "apigee_env_hostnames" {
    type = list
    default = ["example.com","myhost.com"]
}

variable "compute_region" {
  type = string
  default = "us-central1"
}

variable "compute_zone" {
  type = string
  default = "us-central1-a"
}

variable "apigee_analytics_region" {
    type = string
    default = "us-central1"
}

variable "apigee_runtime_type" {
    type = string
    default = "HYBRID"
}

variable "apigee_wait_for_complete" {
  type = number
  default = 60 #seconds
}

variable "apigee_wait_for_complete_increments" {
  type = number
  default = 15 #times so 60 seconds * 10 is 10 minutes
}

variable "vpc_subnet_secondary_range_pods" {
  type = string
  default = "gke-secondary-pods"
}

variable "vpc_subnet_secondary_range_services" {
  type = string
  default = "gke-secondary-services"
}

variable "allow_listed_ip" {
  type = string
  description = "IP address allow-listed for the firewall."
  default = "35.235.240.0/20"
}

variable "ssh_user" {
  type = string
  description = "The user name used to ssh into the bastion VM instance"
  sensitive = true
  nullable = false
}