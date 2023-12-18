# Open firewall to allow tunneling through IAP
# SW - this module doesn't apply the source_ranges to the Firewall Rule.
# module "firewall_rules" {
#   source       = "terraform-google-modules/network/google//modules/firewall-rules"
#   project_id   = var.project_id
#   network_name = google_compute_network.vpc_network.name

#   rules = [{
#     name          = "allow-ssh"
#     description   = "allow ssh"
#     direction     = "INGRESS"
#     priority      = 800
#     #source_ranges = var.allow_listed_ips
#     source_ranges = ["35.235.240.0/20"]
#     target_tags   = ["ssh"]
#     allow = [{
#       protocol = "tcp"
#       ports    = ["22"]
#     }]
#     log_config = {
#       metadata = "INCLUDE_ALL_METADATA"
#     }
#   }]
# }


resource "google_compute_firewall" "firewall_rule" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh"]

  source_ranges = var.allow_listed_ips
  # log_config = {
  #     metadata = "INCLUDE_ALL_METADATA"
  # }
}