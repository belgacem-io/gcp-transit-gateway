/******************************************
  Transitivity Gateway.
 *****************************************/
module "transitivity_gateway" {
  source = "../gcp_network_transitivity"
  count = var.mode == "hub" ? 1 : 0

  environment_code             = var.environment_code
  mode                         = "linux"
  project_id                   = var.project_id
  default_region               = var.default_region
  prefix                       = var.prefix
  internal_trusted_cidr_ranges = var.internal_trusted_cidr_ranges
  subnetwork_name              = local.private_subnets[0].subnet_name
  network_name                 = module.main.network_name

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