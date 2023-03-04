output "ilb_id" {
  value = module.squid_proxy_ilbs.forwarding_rule
}

output "proxy_service_accounts" {
  value = module.squid_proxy_service_account.emails_list
}