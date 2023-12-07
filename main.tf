terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "apigee-hybrid-terraform"
  region  = "us-central1"
  zone = "us-central1-a"
}

# enable the required GCP services
resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list_gke)
  project = var.project_id
  service = each.key
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
   
  }

  shielded_instance_config {
    enable_secure_boot =  true

  }

  depends_on = [
    google_project_service.gcp_services
  ]
}

# Create an Apigee Hybrid oraganization
provider "curl" {
//  client_id = "<client id of this app, registered in Azure AD>"
//  resource = "https://vault.azure.net" //example of the scope/resource to call Azure KeyVault APIs
//  tenant_id = "<azure tenant id>"
//  secret = "" //taken from environment variable 'CURL_CLIENT_SECRET'
}

data "curl" "createApigeeHybridOrg" {
  headers = 
  http_method = "POST"
  uri = "https://jsonplaceholder.typicode.com/todos/1"
}

locals {
  json_data = jsondecode(data.curl.createApigeeHybridOrg.response)
}

# Returns all Todos
output "all_todos" {
  value = local.json_data
}

//# Returns the title of todo
output "todo_title" {
  value = local.json_data.title
}

# Create the Apigee Hybrid Organization
resource "null_resource" "create_apigee_hybrid_org" {
  provisioner "local-exec" {
      command = "${path.module}/create_apigee_org.py -a ${data.aws_caller_identity.current.account_id} -t aws_role"
  }

  depends_on = ["aws_iam_role.cloudability-role"]
}