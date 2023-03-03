module "nethub" {
  source = "./modules/gcp_network"

  prefix                        = "nethub"
  mode                          = "hub"
  environment_code              = "demo"
  network_name                  = "hub"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false

  public_subnets = [
    for subnet in var.hub_public_subnets :merge({ project_name : var.project_id }, subnet)
  ]
  private_subnets = [
    for subnet in var.hub_private_subnets :merge({ project_name : var.project_id }, subnet)
  ]
  private_svc_connect_subnets = [
    for subnet in var.hub_private_svc_connect_subnets :
    merge({ project_name : var.project_id }, subnet)
  ]
}

module "netspoke1" {
  source                        = "./modules/gcp_network"
  prefix                        = "netspoke1"
  mode                          = "spoke"
  environment_code              = "demo"
  network_name                  = "spoke2"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link
  org_nethub_tgw_service_attachment_id = module.nethub.tgw_service_attachment_id

  private_subnets = [
    for subnet in var.spoke1_private_subnets :merge({ project_name : var.project_id }, subnet)
  ]

  depends_on = [
    module.nethub
  ]
}

module "netspoke2" {
  source                        = "./modules/gcp_network"
  prefix                        = "netspoke2"
  mode                          = "spoke"
  environment_code              = "demo"
  network_name                  = "spoke2"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link
  org_nethub_tgw_service_attachment_id = module.nethub.tgw_service_attachment_id

  private_subnets = [
    for subnet in var.spoke2_private_subnets :merge({ project_name : var.project_id }, subnet)
  ]

  depends_on = [
    module.nethub
  ]
}