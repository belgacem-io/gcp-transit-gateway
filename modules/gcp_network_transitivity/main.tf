locals {
  network_egress_internet_tags = ["tgw-egress-internet"]
}
/******************************************
  Squid Proxy.
 *****************************************/
module "squid_gateway" {
  source = "../squid_proxy"

  count = var.mode == "squid" ? 1 : 0

  environment_code             = var.environment_code
  project_id                   = var.project_id
  default_region               = var.default_region
  prefix                       = var.prefix
  internal_trusted_cidr_ranges = var.internal_trusted_cidr_ranges
  subnet_name                  = var.subnetwork_name
  vpc_name                     = var.network_name
  network_tags                 = local.network_egress_internet_tags
}

/******************************************
  Linux Gateway.
 *****************************************/
module "linux_gateway" {
  source = "../linux_tgw"

  count = var.mode == "linux" ? 1 : 0

  environment_code             = var.environment_code
  project_id                   = var.project_id
  default_region               = var.default_region
  prefix                       = var.prefix
  internal_trusted_cidr_ranges = var.internal_trusted_cidr_ranges
  subnet_name                  = var.subnetwork_name
  vpc_name                     = var.network_name
  network_tags                 = local.network_egress_internet_tags
}

/******************************************
  Mandatory firewall Routes
 *****************************************/
resource "google_compute_firewall" "tgw_internet" {

  #[prefix]-[resource]-[location]-[description]-[suffix]
  name      = "${var.prefix}-fw-glb-${var.mode}-tgw-internet"
  project   = var.project_id
  network   = var.network_name
  priority  = 100
  direction = "EGRESS"
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }

  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = var.mode == "squid" ? module.squid_gateway.0.proxy_service_accounts : module.linux_gateway.0.proxy_service_accounts
}
resource "google_compute_route" "tgw_internet" {
  count = var.mode == "squid" ? 1 : 0

  project          = var.project_id
  network          = var.network_name
  priority         = 100
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name             = "${var.prefix}-rt-glb-${var.mode}-tgw-internet"
  description      = "Transitivity route for range internet"
  tags             = local.network_egress_internet_tags
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}
/******************************************
  Transitivity Routes
 *****************************************/

resource "google_compute_route" "tgw_routes_trusted" {
  for_each = var.mode == "squid" ? toset(var.internal_trusted_cidr_ranges) : toset([])

  project      = var.project_id
  network      = var.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name         = "${var.prefix}-rt-glb-${var.mode}-tgw-${replace(replace(each.value, "/", "-"), ".", "-")}"
  description  = "Transitivity route for range ${each.value}"
  dest_range   = each.value
  next_hop_ilb = var.mode == "squid" ? module.squid_gateway.0.ilb_id : module.linux_gateway.0.ilb_id
}

resource "google_compute_route" "tgw_route_internet" {
  count = var.mode == "squid" ? 1 : 0

  project      = var.project_id
  network      = var.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name         = "${var.prefix}-rt-glb-${var.mode}-tgw-internet"
  description  = "Transitivity route for range internet"
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = var.mode == "squid" ? module.squid_gateway.0.ilb_id : module.linux_gateway.0.ilb_id
}