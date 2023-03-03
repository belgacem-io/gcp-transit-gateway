data "google_compute_subnetwork" "private_svc_connect_subnet" {

  for_each = var.mode == "hub" ? toset(local.private_svc_connect_subnets.*.subnet_name) : toset([])

  name    = each.value
  project = var.project_id
  region  = var.default_region

  depends_on = [
    module.main
  ]
}

/******************************************
  Squid Proxy.
 *****************************************/
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
  subnet_name                  = local.private_subnets[0].subnet_name
  vpc_name                     = module.main.network_name
  network_internet_egress_tag  = var.network_internet_egress_tag

  depends_on = [
    module.main
  ]
}
/******************************************
  Private Google APIs DNS Zone & records.
 *****************************************/
module "private_service_connect" {
  source  = "terraform-google-modules/network/google//modules/private-service-connect"
  version = "~> 5.2"

  count = var.mode == "hub" && var.private_svc_connect_ip !=null ? 1 : 0

  forwarding_rule_name         = "privategoogleapi"
  private_service_connect_name = "${var.environment_code}-gip-psconnect"
  project_id                   = var.project_id
  network_self_link            = module.main.network_self_link
  private_service_connect_ip   = var.private_svc_connect_ip
  forwarding_rule_target       = "all-apis"
}


/******************************************
  Mandatory firewall rules
 *****************************************/

resource "google_compute_route" "transitivity_routes" {
  for_each = var.mode == "hub" ? toset(var.internal_trusted_cidr_ranges) : toset([])

  project      = var.project_id
  network      = module.main.network_name
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name         = "${var.prefix}-rt-glb-${var.network_name}-${replace(replace(each.value, "/", "-"), ".", "-")}"
  description  = "Transitivity route for range ${each.value}"
  dest_range   = each.value
  next_hop_ilb = module.transitivity_gateway.0.ilb_id
}