/******************************************
  Mandatory firewall rules
 *****************************************/
resource "google_compute_firewall" "allow_ingress" {
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name      = "${var.prefix}-fw-glb-allow-linuxtgwt-ingress"
  network   = var.network_name
  project   = var.project_id
  direction = "INGRESS"
  priority  = 1000

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [
      {
        metadata = "INCLUDE_ALL_METADATA"
      }
    ] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  allow {
    protocol = "all"
  }

  source_ranges           = var.source_trusted_cidr_ranges
  target_service_accounts = module.service_account.emails_list
}

resource "google_compute_firewall" "allow_egress" {
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name      = "${var.prefix}-fw-glb-allow-linuxtgwt-egress"
  network   = var.network_name
  project   = var.project_id
  direction = "EGRESS"
  priority  = 1000

  dynamic "log_config" {
    for_each = var.firewall_enable_logging == true ? [
      {
        metadata = "INCLUDE_ALL_METADATA"
      }
    ] : []

    content {
      metadata = log_config.value.metadata
    }
  }

  allow {
    protocol = "all"
  }

  destination_ranges      = var.source_trusted_cidr_ranges
  target_service_accounts = module.service_account.emails_list
}

resource "google_project_iam_member" "os_login_bindings" {
  for_each = toset(var.authorized_members)
  project  = var.project_id
  role     = "roles/compute.osLogin"
  member   = each.key
}

module "iap_tunneling" {
  source  = "terraform-google-modules/bastion-host/google//modules/iap-tunneling"
  version = "~> 5.1"

  #[prefix]-[resource]-[location]-[description]-[suffix]
  fw_name_allow_ssh_from_iap = "${var.prefix}-iap-glb-allow-iap-to-tunnel"
  project                    = var.project_id
  network                    = var.network_name
  service_accounts           = module.service_account.emails_list
  instances                  = []
  members                    = var.authorized_members
}