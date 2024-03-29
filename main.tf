locals {
  environment_code  = "demo"
  prefix            = "hbe-${local.environment_code}"
  public_domain = "hbe.com"
  private_domain = "hbe.local"
}

/******************************************
  Network.
 *****************************************/

module "nethub" {
  source = "./modules/gcp_network"

  prefix                        = local.prefix
  environment_code              = local.environment_code
  mode                          = "hub"
  network_suffix                  = "hub"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  nat_enabled                   = true
  public_subnets                = var.hub_public_subnets
  private_subnets               = var.hub_private_subnets
  allow_egress_ranges           = ["0.0.0.0/0"]
  allow_ingress_ranges          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_trusted_cidr_ranges  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  private_domain = local.private_domain
  public_domain = local.public_domain

}

module "nethub_bastion" {
  source                      = "./modules/gcp_bastion_host"
  prefix                      = "${local.prefix}-hub"
  environment_code            = local.environment_code
  authorized_members          = []
  instance_name               = "hub-bastion"
  network_self_link           = module.nethub.network_self_link
  project_id                  = var.project_id
  region                      = var.default_region
  subnet_self_link            = module.nethub.subnets_self_links[0]
  network_internet_egress_tag = module.nethub.net_tag_internet_egress

  depends_on = [
    module.nethub
  ]
}

module "netspoke1" {
  source                        = "./modules/gcp_network"
  prefix                        = "${local.prefix}-spoke1"
  environment_code              = local.environment_code
  mode                          = "spoke"
  network_suffix                  = "spoke1"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link
  private_subnets               = var.spoke1_private_subnets
  allow_egress_ranges           = ["0.0.0.0/0"]
  allow_ingress_ranges          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_trusted_cidr_ranges  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  private_domain = local.private_domain
  public_domain = local.public_domain

  depends_on = [
    module.nethub
  ]
}

module "netspoke1_bastion" {
  source                      = "./modules/gcp_bastion_host"
  prefix                      = "${local.prefix}-spoke1"
  environment_code            = local.environment_code
  authorized_members          = []
  instance_name               = "spoke1-bastion"
  network_self_link           = module.netspoke1.network_self_link
  project_id                  = var.project_id
  region                      = var.default_region
  subnet_self_link            = module.netspoke1.subnets_self_links[0]
  network_internet_egress_tag = module.nethub.net_tag_internet_egress

  depends_on = [
    module.netspoke1
  ]
}

module "netspoke2" {
  source                        = "./modules/gcp_network"
  prefix                        = "${local.prefix}-spoke2"
  environment_code              = local.environment_code
  mode                          = "spoke"
  network_suffix                  = "spoke2"
  project_id                    = var.project_id
  default_region                = var.default_region
  shared_vpc_host               = false
  dns_enable_inbound_forwarding = false
  org_nethub_project_id         = var.project_id
  org_nethub_vpc_self_link      = module.nethub.network_self_link
  private_subnets               = var.spoke2_private_subnets
  allow_egress_ranges           = ["0.0.0.0/0"]
  allow_ingress_ranges          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_trusted_cidr_ranges  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  private_domain = local.private_domain
  public_domain = local.public_domain

  depends_on = [
    module.nethub
  ]
}

module "netspoke2_bastion" {
  source                      = "./modules/gcp_bastion_host"
  prefix                      = "${local.prefix}spoke2"
  environment_code            = local.environment_code
  authorized_members          = []
  instance_name               = "spoke2-bastion"
  network_self_link           = module.netspoke2.network_self_link
  project_id                  = var.project_id
  region                      = var.default_region
  subnet_self_link            = module.netspoke2.subnets_self_links[0]
  network_internet_egress_tag = module.nethub.net_tag_internet_egress

  depends_on = [
    module.netspoke2
  ]
}