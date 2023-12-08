terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.compute_region
  zone = var.compute_zone
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

# Create the Apigee Hybrid Organization
resource "null_resource" "create_apigee_hybrid_org" {
  provisioner "local-exec" {
      command = "${path.module}/python_scripts/create_apigee_org.py -o ${var.apigee_org_name} -a ${var.apigee_analytics_region}"
  }
}

# Create the Apigee Hybrid Environment and Environment Group
# This may not be needed since we have a Terraform module to create envs and env groups.
# resource "null_resource" "create_apigee_hybrid_env_env_group" {
#   provisioner "local-exec" {
#       command = "${path.module}/python_scripts/create_apigee_env.py -o ${var.apigee_org_name} -e ${var.apigee_env_name} -g ${var.apigee_env_group_name} -n ${var.apigee_env_hostnames}"
#   }
# }