/*
 * Hub & Spoke Peering Transitivity with Gateway VMs
 */

locals {
  stripped_vpc_name = replace(var.vpc_name, "vpc-", "")
}

module "service_account" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.1"

  project_id    = var.project_id
  names         = ["linux-tgw"]
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
  ]
}

module "tgw_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 8.0"

  can_ip_forward = true
  disk_size_gb   = 10
  name_prefix    = var.prefix
  network        = var.vpc_name
  project_id     = var.project_id
  region         = var.default_region
  subnetwork         = var.subnet_name
  subnetwork_project = var.project_id
  machine_type       = var.instance_type

  service_account = {
    email  = module.service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    user-data              = templatefile("${path.module}/files/gw.yaml", {
      trusted_ip_ranges = join(",", var.internal_trusted_cidr_ranges)
    })
    block-project-ssh-keys = "true"
  }

  source_image         = "cos-stable-93-16623-102-23"
  source_image_project = "cos-cloud"
}

module "migs" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 8.0"

  project_id        = var.project_id
  region            = var.default_region
  target_size       = 3
  #[prefix]-[resource]-[location]-[description]-[suffix]
  hostname          = "${var.prefix}-mig-${var.default_region}-linuxtgwt"
  instance_template = module.tgw_template.self_link
  /* autoscaler */
  autoscaling_enabled          = var.autoscaling_enabled
  max_replicas                 = var.max_replicas
  min_replicas                 = var.min_replicas
  cooldown_period              = var.cooldown_period
  autoscaling_cpu              = var.autoscaling_cpu
  autoscaling_metric           = var.autoscaling_metric
  autoscaling_lb               = var.autoscaling_lb
  autoscaling_scale_in_control = var.autoscaling_scale_in_control

  update_policy     = [
    {
      max_surge_fixed              = 4
      max_surge_percent            = null
      instance_redistribution_type = "NONE"
      max_unavailable_fixed        = 4
      max_unavailable_percent      = null
      min_ready_sec                = 180
      minimal_action               = "RESTART"
      type                         = "OPPORTUNISTIC"
      replacement_method           = "SUBSTITUTE"
    }
  ]
}

module "ilbs" {
  source  = "GoogleCloudPlatform/lb-internal/google"
  version = "~> 5.0"

  region                  = var.default_region
  #[prefix]-[resource]-[location]-[description]-[suffix]
  name                    = "${var.prefix}-ilb-${var.default_region}-linuxtgwt"
  ports                   = null
  all_ports               = true
  global_access           = true
  network                 = var.vpc_name
  subnetwork              = var.subnet_name
  firewall_enable_logging = true
  target_service_accounts = [module.service_account.email]
  source_tags             = null
  target_tags             = null
  create_backend_firewall = false
  backends                = [
    { group = module.migs.instance_group, description = "" },
  ]

  health_check = {
    type                = "tcp"
    check_interval_sec  = 5
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = null
    proxy_header        = "NONE"
    port                = 22
    port_name           = null
    request             = null
    request_path        = null
    host                = null
    enable_log          = false
  }
  project = var.project_id
}