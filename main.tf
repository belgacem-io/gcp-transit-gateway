module "nethub" {
  source = "./modules/gcp_network"

  prefix                        = "poc-tgw-demo"
  mode                          = "hub"
  environment_code              = "demo"
  network_name                  = "hub"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false

  public_subnets = var.hub_public_subnets
  private_subnets = var.hub_private_subnets
  private_svc_connect_subnets = var.hub_private_svc_connect_subnets
}

module "netspoke1" {
  source                        = "./modules/gcp_network"
  prefix                        = "poc-tgw-demo1"
  mode                          = "spoke"
  environment_code              = "demo"
  network_name                  = "spoke1"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link

  private_subnets = var.spoke1_private_subnets

  depends_on = [
    module.nethub
  ]
}

module "netspoke2" {
  source                        = "./modules/gcp_network"
  prefix                        = "poc-tgw-demo2"
  mode                          = "spoke"
  environment_code              = "demo"
  network_name                  = "spoke2"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link

  private_subnets = var.spoke2_private_subnets

  depends_on = [
    module.nethub
  ]
}