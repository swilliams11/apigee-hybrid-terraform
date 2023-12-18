
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest?tab=inputs
# module "kubernetes-engine" {
#   source  = "terraform-google-modules/kubernetes-engine/google"
#   version = "29.0.0"
#   # insert the 6 required variables here
#   ip_range_pods = "gke-secondary-pods"
#   ip_range_services = "gke-secondary-services"
#   name = "cluster-1"
#   network = "apigee-vpc"
#   project_id = var.project_id
#   subnetwork = "us-central1"
# }

# Create a VM that can be used to access the K8S cluster.
resource "google_compute_instance" "vm_instance" {
  name         = "apigee-k8s-cluster-bastion"
  machine_type = "f1-micro"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  #metadata_startup_script = "gcloud components install kubectl"
  #metadata_startup_script = "${file("${path.module}/update_storage_class.sh")}"

  # provisioner "remote-exec" {
  #    connection {
  #     #host        = google_compute_address.static.address
  #     # host = self.network_interface[0].network_ip
  #     host = self.name
  #     type        = "ssh"
  #     user        = var.ssh_user
  #     timeout     = "120s"
  #     #private_key = file(var.privatekeypath)
  #   }
  #   inline = [
  #     "gcloud container clusters get-credentials cluster-1",
  #     "kubectl apply -f ./storageclass.yaml",
  #     "kubectl patch storageclass standard-rwo -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'",
  #     "kubectl patch storageclass apigee-sc -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'",
  #     "kubectl get sc",
  #     "gcloud container clusters update ${var.name} --workload-pool=${var.project_id}.svc.id.goog --project ${var.project_id} --region ${var.region}",
  #     "gcloud container clusters describe ${var.name} --project ${var.project_id} --region ${var.region} | grep -i \"workload\""
  #   ]
  # }
  depends_on = [
    module.create_gke_cluster
  ]
}

# Create Apply the storageclass.yaml file to the cluster
resource "null_resource" "apply_storage_class_to_gke" {

  provisioner "local-exec" {
    command = "${path.module}/update_storage_class.sh"
  }

  depends_on = [google_compute_instance.vm_instance]
}

# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/private-cluster
module "create_gke_cluster" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.project_id
  name                       = var.name
  region                     = var.region
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  deletion_protection        = false
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = false
  filestore_csi_driver       = false
  enable_private_endpoint    = true
  enable_private_nodes       = true
  master_authorized_networks = [
    {
      cidr_block   = "10.20.0.0/20"
      display_name = "us-central1"
    }
  ]
  # IP range in CIDR notation used for the hosted master network
  master_ipv4_cidr_block       = "10.0.0.0/28"
  master_global_access_enabled = false
  node_pools = [
    {
      name            = "apigee-data"
      machine_type    = "e2-standard-4"
      node_locations  = var.node_locations
      min_count       = 1
      max_count       = 1
      local_ssd_count = 0
      spot            = false
      disk_size_gb    = 50
      disk_type       = "pd-standard"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      enable_gvnic    = false
      logging_variant = "DEFAULT"
      auto_repair     = true
      auto_upgrade    = true
      #service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
    {
      name            = "apigee-runtime"
      machine_type    = "e2-standard-4"
      node_locations  = var.node_locations
      min_count       = 1
      max_count       = 1
      local_ssd_count = 0
      spot            = false
      disk_size_gb    = 50
      disk_type       = "pd-standard"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      enable_gvnic    = false
      logging_variant = "DEFAULT"
      auto_repair     = true
      auto_upgrade    = true
      #service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 1
    },
    {
      name            = "default-pool"
      machine_type    = "e2-standard-4"
      node_locations  = var.node_locations
      min_count       = 1
      max_count       = 1
      local_ssd_count = 0
      spot            = false
      disk_size_gb    = 50
      disk_type       = "pd-standard"
      image_type      = "COS_CONTAINERD"
      enable_gcfs     = false
      enable_gvnic    = false
      logging_variant = "DEFAULT"
      auto_repair     = true
      auto_upgrade    = true
      #service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible              = false
      initial_node_count       = 1
      remove_default_node_pool = false
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    apigee-data = {
      apigee-data = true
    },
    apigee-data = {
      apigee-runtime = true
    },
    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    apigee-data = {
      node-pool-metadata-custom-value = "apigee-data"
    },
    apigee-runtime = {
      node-pool-metadata-custom-value = "apigee-runtime"
    },
    default-node-pool = {
      node-pool-metadata-custom-value = "default-node-pool"
    }

  }

  # allows you to configure node taints to specify restrictions on which pods can be scheduled on them 
  node_pools_taints = {
    all = []

    # default-node-pool = [
    #   {
    #     key    = "default-node-pool"
    #     value  = false
    #     effect = "PREFER_NO_SCHEDULE"
    #   },
    # ]
  }

  node_pools_tags = {
    all = []

    apigee-data = [
      "apigee-data",
    ]

    apigee-runtime = [
      "apigee-runtime",
    ]

    default-node-pool = [
      "default-node-pool",
    ]
  }
}


# The following section is from Bard, and I thin, it hallucinated.
# get the k8s credentials for the cluster
# module "gke_auth" {
#   source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"

#   project_id           = var.project_id
#   cluster_name         = var.name
#   location             = module.gke.location
#   use_private_endpoint = true
# }

# resource "google_client" "gke_credentials" {
#   project = var.project_id
#   resource = "projects/${var.project_id}/locations/${var.region}/clusters/${var.name}"
#   service = "container.googleapis.com"
#   version = "v1"

#   method = "get"
# }

# output "credentials" {
#   value = google_client.gke_credentials.body.masterAuth.token
# }

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform
# Get the k8s credentials so that we can configure it.check
# gcloud container clusters get-credentials cluster-name
# resource "null_resource" "apply_storage_class_to_ks_cluster" {

#   provisioner "local-exec" {
#     command = "${path.module}/update_storage_class.sh" 
#   }

#   depends_on = [google_compute_instance.vm_instance]
# }

