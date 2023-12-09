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

variable "apigee_env_name" {
    type = string
    default = "hybrid_env"
}

variable "apigee_env_group_name" {
    type = string
    default = "hybrid_group"
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