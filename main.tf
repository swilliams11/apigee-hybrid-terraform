terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.9.0"
    }
  }
}

# # google_client_config and kubernetes provider must be explicitly specified like the following.
# data "google_client_config" "default" {
#   access_token = ""
# }

provider "kubernetes" {
  #host                   = "https://${module.gke.endpoint}"
  # token                  = data.google_client_config.default.access_token
  #cluster_ca_certificate = base64decode(module.gke.ca_certificate)
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
   disable_dependent_services = true
}

resource "google_compute_network" "vpc_network" {
  name = "apigee-vpc"
  auto_create_subnetworks = false

  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_compute_subnetwork" "us_central1" {
  name          = "us-central1"
  ip_cidr_range = "10.20.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  secondary_ip_range {
    range_name    = var.vpc_subnet_secondary_range_pods
    ip_cidr_range = "10.188.0.0/20"
  }
  secondary_ip_range {
    range_name    = var.vpc_subnet_secondary_range_services
    ip_cidr_range = "10.192.0.0/20"
  }
}

# resource "google_compute_subnetwork" "us_west1" {
#   name          = "us-west1"
#   ip_cidr_range = "10.5.0.0/20"
#   region        = "us-west1"
#   network       = google_compute_network.vpc_network.id
#   secondary_ip_range {
#     range_name    = "tf-test-secondary-range-update1"
#     ip_cidr_range = "10.192.0.0/20"
#   }
# }


# Create the Apigee Hybrid Organization
resource "null_resource" "create_apigee_hybrid_org" {

  triggers = {
    org_name      = var.apigee_org_name
    analytics_region       = var.apigee_analytics_region
    apigee_wait_for_complete = var.apigee_wait_for_complete
    apigee_wait_for_complete_increments = var.apigee_wait_for_complete_increments
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/python_scripts/create_apigee_org.py -o ${var.apigee_org_name} --analytics_region ${var.apigee_analytics_region} -t ${var.apigee_wait_for_complete} -i ${var.apigee_wait_for_complete_increments}" 
  }

  provisioner "local-exec" {
    when    = destroy
    command = "python3 ${path.module}/python_scripts/delete_apigee_org.py -o ${self.triggers.org_name} -t ${self.triggers.apigee_wait_for_complete} -i ${self.triggers.apigee_wait_for_complete_increments}"
  }
   
  depends_on = [google_project_service.gcp_services]
}

# Create the Apigee Hybrid Environment and Environment Group
# This may not be needed since we have a Terraform module to create envs and env groups.
# resource "null_resource" "create_apigee_hybrid_env_env_group" {
#   provisioner "local-exec" {
#       command = "${path.module}/python_scripts/create_apigee_env.py -o ${var.apigee_org_name} -e ${var.apigee_env_name} -g ${var.apigee_env_group_name} -n ${var.apigee_env_hostnames}"
#   }
# }

resource "google_apigee_environment" "create_apigee_env" {
  name         = var.apigee_env_name
  description  = "Apigee Environment"
  display_name = var.apigee_env_name
  org_id       = var.apigee_org_name_full_path

   depends_on = [
    null_resource.create_apigee_hybrid_org
  ]
}

resource "google_apigee_envgroup" "create_apigee_env_grp" {
  name      = "my-envgroup"
  hostnames = [var.apigee_env_hostname]
  org_id    = var.apigee_org_name_full_path
  depends_on = [
    null_resource.create_apigee_hybrid_org
  ]
}

resource "google_apigee_envgroup_attachment" "apigee_env_attachment" {
  envgroup_id  = google_apigee_envgroup.create_apigee_env_grp.id
  environment  = google_apigee_environment.create_apigee_env.name

  # depends_on = [
  #   google_apigee_environment.create_apigee_env,
  #   google_apigee_envgroup.create_apigee_env_grp
  # ]
}


module "gke" {
  source     = "./gke"
  project_id = var.project_id
  region   = var.compute_region

  ip_range_pods = var.vpc_subnet_secondary_range_pods
  ip_range_services = var.vpc_subnet_secondary_range_services
  name = "cluster-1" # cluster name
  network = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.us_central1.name

  depends_on = [ 
    google_project_service.gcp_services,
    google_compute_network.vpc_network ]
}


