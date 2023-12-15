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

variable "gke_creds"{
    type = string
    description = "GKE cluster credentials"
}