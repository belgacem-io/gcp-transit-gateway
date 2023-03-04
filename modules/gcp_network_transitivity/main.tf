/******************************************
  Squid Proxy.
 *****************************************/
locals {
  network_egress_internet_tags = ["tgw-egress-internet"]
}
module "transitivity_gateway" {
  source = "../squid_proxy"

  count = var.mode == "hub" ? 1 : 0

  environment_code             = var.environment_code
  project_id                   = var.project_id
  default_region               = var.default_region
  prefix                       = var.prefix
  internal_trusted_cidr_ranges = var.internal_trusted_cidr_ranges
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name                         = "${var.prefix}-tgw-${var.default_region}"
  subnet_name                  = var.subnetwork_name
  vpc_name                     = var.network_name
  network_tags                 = local.network_egress_internet_tags
}

/******************************************
  Mandatory firewall Routes
 *****************************************/
resource "google_compute_firewall" "transitivity_internet" {
  count = var.mode == "hub" ? 1 : 0

  #[prefix]-[resource]-[location]-[description]-[suffix]
  name      = "${var.prefix}-fw-glb-tgw-internet"
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
  target_service_accounts = module.transitivity_gateway.0.proxy_service_accounts
}
resource "google_compute_route" "transitivity_internet" {
  count = var.mode == "hub" ? 1 : 0

  project          = var.project_id
  network          = var.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name             = "${var.prefix}-rt-glb-tgw-internet"
  description      = "Transitivity route for range internet"
  tags             = local.network_egress_internet_tags
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}
/******************************************
  Transitivity Routes
 *****************************************/

resource "google_compute_route" "transitivity_routes_trusted" {
  for_each = var.mode == "hub" ? toset(var.internal_trusted_cidr_ranges) : toset([])

  project      = var.project_id
  network      = var.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name         = "${var.prefix}-rt-glb-${replace(replace(each.value, "/", "-"), ".", "-")}"
  description  = "Transitivity route for range ${each.value}"
  dest_range   = each.value
  next_hop_ilb = module.transitivity_gateway.0.ilb_id
}

resource "google_compute_route" "transitivity_route_internet" {
  count = var.mode == "hub" ? 1 : 0

  project      = var.project_id
  network      = var.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name         = "${var.prefix}-rt-glb-internet"
  description  = "Transitivity route for range internet"
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = module.transitivity_gateway.0.ilb_id
}