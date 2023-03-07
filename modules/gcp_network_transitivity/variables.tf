variable "project_id" {
  type        = string
  description = "Project ID for Private Shared VPC."
}

variable "prefix" {
  type        = string
  description = "Prefix applied to service to all resources."
}

variable "network_name" {
  type        = string
  description = "The network name."
}
variable "subnetwork_name" {
  type        = string
  description = "The subnetwork name."
}

variable "mode" {
  type        = string
  description = "Network deployment mode, should be set to `squid` or `linux`."
  default     = null
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization."
}

variable "default_region" {
  type        = string
  description = "Default region 1 for subnets and Cloud Routers"
}

variable "internal_trusted_cidr_ranges" {
  description = "Internal trusted ip ranges. Must be set to private ip ranges"
  type        = list(string)
}

variable "org_private_ca" {
  type        = object({
    cert = string
    key  = string
  })
  default     = null
  description = "The Organization CertificateAuthority's certificate. Required in squid mode"
}