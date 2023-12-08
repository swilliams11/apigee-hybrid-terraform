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