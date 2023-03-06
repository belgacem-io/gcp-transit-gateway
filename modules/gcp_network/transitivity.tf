/******************************************
  Transitivity Gateway.
 *****************************************/
module "transitivity_gateway" {
  source = "../gcp_network_transitivity"
  count = var.mode == "hub" ? 1 : 0

  environment_code             = var.environment_code
  mode                         = "squid"
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
