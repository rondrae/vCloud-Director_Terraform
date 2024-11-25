locals {
  # Change Per Tenant
  customer_site_number                                  = "0" # Just the number no need to add the s
  tenant_customer_code                                 = ""
  tenant_customer_name                                 = ""
  tenant_vdc_total_cpu_count                           = 0
  tenant_vdc_total_memory_gb_ordered                   = 0
  tenant_vdc_storage_mb_limit                          = 0 * 1024 # This value needs to in MB 1024 = 1024MB = 1GB
  tenant_vdc_instance_number                           = 001
  tenant_edge_nsxt_instance_number                     = 001
  tenant_edge_nsxt_external_ip                         = ""         # The Primary External IP You have to declare it, sorry ie "z.z.z.z"
  tenant_edge_nsxt_additional_ip_auto_assign           = false      # true = auto assign, false = manual
  tenant_edge_nsxt_additional_ip_auto_assign_count     = 1          # The number of IPs to allocate only if auto assign is true
  tenant_edge_nsxt_additional_ip_manual_additional_ips = []         # Create a list of additional IPs to allocate ie ["x.x.x.x","y.y.y.y"] only if auto assign is false
  tenant_edge_nsxt_alb_feature_set                     = "STANDARD" # Either "STANDARD" or PREMIUM
  tenant_edge_nsxt_alb_enable_transparent_mode         = false      # Either True/False, used to expose client IP to virtual server
  tenant_edge_nsxt_alb_service_network                 = "192.168.255.1/25"
  tenant_edge_nsxv_instance_number                     = 1
  #
  # Control the deployment options
  #
  create_tenant_org                            = false
  create_tenant_vdc                            = false
  create_tenant_edge_nsxt                      = false
  enable_tenant_edge_nsxt_alb                  = false
  create_tenant_edge_nsxv                      = false
  create_tenant_vdc_external_network           = false
  create_tenant_vdc_isolated_networks          = false
  create_tenant_vdc_nsxt_routed_networks       = false
  create_tenant_vdc_nsxv_routed_networks       = false
  create_tenant_vdc_routed_networks_snats      = false
  create_tenant_ipset_isolated_networks        = false
  create_tenant_ipset_routed_networks          = false
  create_tenant_ipset_cloudflare_networks      = false
  create_tenant_ipset_exchange_online_networks = false
  create_tenant_ipset_rapid7_hosts             = false
  create_tenant_ipset_customer_kms              = false
  create_tenant_ipset_quad9_dns                = false
  create_tenant_ipset_nist_ntp                 = false
  create_tenant_ipset_custom                   = false
  create_tenant_catalog                        = false


  # Example for specifing isolated network, add each network as a new line
  # "<NETWORK NAME>" = { cidr = "x.x.x.x/x", pool = "x.x.x.start-x.x.x.end", description = "Free text field what is the purpose of the network? LAN DMZ etc"}
  # e.g "11CAL01-913-001" = { cidr = "192.168.99.1/24", pool = "192.168.99.2-192.168.99.254", description = "Backend LAN", dns1 = var.quad9_dns1, dns2 = var.quad9_dns2 }
  # dns1 and 2 can either be var.quad9_dns1/2 or string of your choice "x.x.x.x"
  isolated_networks = {
    # "ISOLATED_EXAMPLE_001" = { cidr = "192.168.99.0/24", gw_octet = 1, pool = "192.168.99.5-192.168.99.250", description = "Isolated Backend LAN", dns1 = "9.9.9.9", dns2 = var.quad9_dns2 }
  }
  # Example for specifing isolated network, add each network as a new line
  # "<NETWORK NAME>" = { cidr = "x.x.x.x/x", pool = "x.x.x.start-x.x.x.end", description = "Free text field what is the purpose of the network? LAN DMZ etc"}
  # e.g "11CAL01-913-001" = { cidr = "192.168.99.1/24", pool = "192.168.99.2-192.168.99.254", description = "Backend LAN", dns1 = var.quad9_dns1, dns2 = var.quad9_dns2 }
  # dns1 and 2 can either be var.quad9_dns1/2 or string of your choice "x.x.x.x"
  routed_networks = {
    #"ROUTED_EXAMPLE_001" = { cidr = "192.168.98.0/24", gw_octet = 1, pool = "192.168.98.5-192.168.98.250", description = "Routed Backend LAN", dns1 = var.quad9_dns1, dns2 = var.quad9_dns2, create_snat = true, external_ip = local.tenant_edge_nsxt_external_ip }
  }

  custom_ipsets = {
    #"IPSET_EXAMPLE_001" = { description = "Custom IPSET 001 ", ip_addresses = ["1.1.1.1","2.2.2.2"] }
  }
  # Use this properties only if required/customer is normally the best practice
  override_storage_policy   = false
  tenant_vdc_storage_policy = "" # This is the shared storage policy this is used now instead of / customer ones

  # Use this property only if required
  override_org_name = false
  tenant_org_name   = ""

  # Build the customer prefix for naming, please don't change
  customer_customer_prefix = upper("${local.customer_site_number}${local.tenant_customer_code}")
  # Build the name of the VDC and EDGE
  tenant_vdc_name       = "${local.customer_customer_prefix}-911-${format("%03d", local.tenant_vdc_instance_number)}"
  tenant_edge_nsxt_name = "${local.customer_customer_prefix}-91E-${format("%03d", local.tenant_edge_nsxt_instance_number)}"
  tenant_edge_nsxv_name = "${local.customer_customer_prefix}-91E-${format("%03d", local.tenant_edge_nsxv_instance_number)}"
  tenant_catalog_name   = "${local.customer_customer_prefix}-914-${format("%03d", local.tenant_vdc_instance_number)}"
  # Add a buffer to the cpu and memory limits 1.10 would add 10%, 1 is 1 to 1
  tenant_vdc_cpu_buffer_percent    = 1 # 1.10 default 
  tenant_vdc_memory_buffer_percent = 1 # 1.10 default
}

# Configure the VMware vCloud Director Provider, this version should be in lock step with the modules
terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.9.0"
    }
  }
}
provider "vcd" {
  user                 = var.vcd_admin_user
  password             = var.vcd_admin_pass
  org                  = var.vcd_admin_org # System
  url                  = var.vcd_url[local.customer_site_number]
  max_retry_timeout    = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
  auth_type            = var.vcd_auth_type # "integrated"
}

# This module will create the tenant organization within vlcoud
module "vcloud_tenant_org_001" {
  # Added ability to skip the creation on an org based on a local var, as it might have previously been created
  count = local.create_tenant_org == true ? 1 : 0

  source               = "../../modules/services/vcloud_tenant_org"
  tenant_customer_org  = local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  tenant_customer_name = local.tenant_customer_name
  customer_site_number  = local.customer_site_number
}

# This module will create the tenant VDC, the customer org is feed from the output of the "vcloud_tenant_org" module
# This helps with chaining terraform to create the components in the desired order
module "vcloud_tenant_vdc_001" {
  # Added ability to skip the creation on an vdc based on a local var, as it might have previously been created
  count = local.create_tenant_vdc == true ? 1 : 0

  source                             = "../../modules/services/vcloud_tenant_vdc"
  tenant_customer_org                = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  tenant_customer_vdc                = local.tenant_vdc_name
  tenant_customer_prefix             = local.customer_customer_prefix
  tenant_customer_name               = local.tenant_customer_name
  tenant_vdc_total_cpu_count         = local.tenant_vdc_total_cpu_count
  tenant_vdc_cpu_mhz_speed           = var.tenant_vdc_cpu_mhz_speed[local.customer_site_number]
  tenant_vdc_total_memory_gb_ordered = local.tenant_vdc_total_memory_gb_ordered
  tenant_vdc_storage_mb_limit        = local.tenant_vdc_storage_mb_limit
  tenant_vdc_vm_quota                = local.tenant_vdc_total_cpu_count
  customer_site_number                = local.customer_site_number
  tenant_provider_vdc                = var.vcd_provider_vdc[local.customer_site_number]
  tenant_provider_network_pool       = var.vcd_provider_network_pool[local.customer_site_number]

  tenant_vdc_cpu_buffer_percent    = local.tenant_vdc_cpu_buffer_percent
  tenant_vdc_memory_buffer_percent = local.tenant_vdc_memory_buffer_percent

  tenant_vdc_storage_policy = local.override_storage_policy == true ? local.tenant_vdc_storage_policy : var.tenant_vdc_storage_policy[local.customer_site_number]
}

module "vcloud_tenant_vdc_edge_nsxv_001" {
  # Added ability to skip the creation on an edge based on a local var, or at least that is the plan
  count                             = local.create_tenant_edge_nsxv == true ? 1 : 0
  source                            = "../../modules/services/vcloud_tenant_vdc_edge"
  tenant_customer_org               = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  tenant_customer_vdc               = local.create_tenant_vdc == true ? module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_name : local.tenant_vdc_name
  tenant_customer_edge              = local.tenant_edge_nsxv_name
  tenant_customer_name              = local.tenant_customer_name
  edge_size                         = "compact"
  edge_enable_ha                    = false
  edge_enable_rate_limit            = false
  edge_incoming_rate_limit_Mbps     = 0
  edge_outgoing_rate_limit_Mbps     = 0
  customer_site_number               = local.customer_site_number
  provider_external_network_name    = var.vcd_provider_external_network_name[local.customer_site_number]
  provider_external_network_netmask = var.vcd_provider_external_network_netmask[local.customer_site_number]
  provider_external_network_gateway = var.vcd_provider_external_network_gateway[local.customer_site_number]
}

## This module will provision an edge gateway within the org and vdc from the modules above.
module "vcloud_tenant_vdc_edge_nsxt_001" {
  # Added ability to skip the creation on an edge based on a local var, or at least that is the plan
  count = local.create_tenant_edge_nsxt == true ? 1 : 0

  source                     = "../../modules/services/vcloud_tenant_vdc_edge_nsxt"
  vcd_tenant_vdc_group_id    = local.create_tenant_vdc == true ? module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_id : null
  tenant_customer_org        = local.override_org_name == true && local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.tenant_customer_code
  tenant_customer_vdc_id     = local.create_tenant_vdc == true ? module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_id : null
  tenant_customer_vdc        = local.create_tenant_vdc == true ? null : local.tenant_vdc_name
  tenant_customer_edge       = local.tenant_edge_nsxt_name
  tenant_customer_name       = local.tenant_customer_name
  tenant_gateway_external_ip = local.tenant_edge_nsxt_external_ip

  tenant_gateway_additional_ip_auto_assign           = local.tenant_edge_nsxt_additional_ip_auto_assign
  tenant_gateway_additional_ip_auto_assign_count     = local.tenant_edge_nsxt_additional_ip_auto_assign_count
  tenant_gateway_additional_ip_manual_additional_ips = local.tenant_edge_nsxt_additional_ip_manual_additional_ips

  customer_site_number = local.customer_site_number

  provider_external_network_name    = var.vcd_provider_gateway_name[local.customer_site_number]
  provider_external_network_netmask = var.vcd_provider_gateway_network_netmask[local.customer_site_number]
  provider_external_network_gateway = var.vcd_provider_gateway_network_gateway[local.customer_site_number]
  provider_edge_cluster_name        = var.vcd_provider_edge_cluster_name[local.customer_site_number]
}

resource "vcd_network_direct" "external_vdc_001" {
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_vdc_external_network == true ? 1 : 0

  org              = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  vdc              = module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_name
  name             = var.vcd_provider_external_network_name[local.customer_site_number]
  external_network = var.vcd_provider_external_network_name[local.customer_site_number]
  description      = "External Network"

}

resource "vcd_network_isolated_v2" "nsxt-backed_vdc_001" {
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  # can't use count and for_each so combined the too
  for_each = {
    for k, v in local.isolated_networks : k => v if local.create_tenant_vdc_isolated_networks == true
  }

  org           = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  owner_id      = module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_id
  name          = each.key
  description   = each.value.description
  gateway       = cidrhost(each.value.cidr, each.value.gw_octet)
  prefix_length = element(split("/", each.value.cidr), 1)
  dns1          = each.value.dns1
  dns2          = each.value.dns2

  static_ip_pool {
    start_address = element(split("-", each.value.pool), 0)
    end_address   = element(split("-", each.value.pool), 1)
  }

}

resource "vcd_network_routed_v2" "nsxt-backed_vdc_001" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  # can't use count and for_each so combined the too
  for_each = {
    for k, v in local.routed_networks : k => v if local.create_tenant_vdc_nsxt_routed_networks == true
  }
  # static
  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  dns1            = each.value.dns1
  dns2            = each.value.dns2
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  # to be provided by the loop
  name          = each.key
  description   = each.value.description
  gateway       = cidrhost(each.value.cidr, each.value.gw_octet)
  prefix_length = element(split("/", each.value.cidr), 1)

  static_ip_pool {
    start_address = element(split("-", each.value.pool), 0)
    end_address   = element(split("-", each.value.pool), 1)
  }

}


resource "vcd_network_routed_v2" "nsxv-backed_vdc_001" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxv_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  # can't use count and for_each so combined the too
  for_each = {
    for k, v in local.routed_networks : k => v if local.create_tenant_vdc_nsxv_routed_networks == true
  }
  # static
  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  dns1            = each.value.dns1
  dns2            = each.value.dns2
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxv_001[0].vcd_tenant_vdc_edge_id

  # to be provided by the loop
  name          = each.key
  description   = each.value.description
  gateway       = cidrhost(each.value.cidr, each.value.gw_octet)
  prefix_length = element(split("/", each.value.cidr), 1)

  static_ip_pool {
    start_address = element(split("-", each.value.pool), 0)
    end_address   = element(split("-", each.value.pool), 1)
  }

}

resource "vcd_nsxt_nat_rule" "nsxt-backed_snat" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  # can't use count and for_each so combined the too
  for_each = {
    for k, v in local.routed_networks : k => v if local.create_tenant_vdc_routed_networks_snats == true && v.create_snat == true
  }
  # static
  org              = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id  = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id
  name             = "SNAT - ${each.key}"
  description      = each.value.description
  rule_type        = "SNAT"
  internal_address = each.value.cidr
  external_address = each.value.external_ip
}

resource "vcd_nsxt_alb_settings" "edge_001" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.enable_tenant_edge_nsxt_alb == true ? 1 : 0

  org                           = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id               = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id
  is_active                     = true
  is_transparent_mode_enabled   = local.tenant_edge_nsxt_alb_enable_transparent_mode
  supported_feature_set         = local.tenant_edge_nsxt_alb_feature_set
  service_network_specification = local.tenant_edge_nsxt_alb_service_network
}

resource "vcd_nsxt_ip_set" "isolated_networks" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  for_each = {
    for k, v in local.isolated_networks : k => v if local.create_tenant_ipset_isolated_networks == true
  }

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "NET_${each.key}"
  description = "${each.value.description} - ${each.value.cidr}"
  ip_addresses = [
    each.value.cidr
  ]
}

resource "vcd_nsxt_ip_set" "routed_networks" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  for_each = {
    for k, v in local.routed_networks : k => v if local.create_tenant_ipset_routed_networks == true
  }

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "NET_${each.key}"
  description = "${each.value.description} - ${each.value.cidr}"
  ip_addresses = [
    each.value.cidr
  ]
}

resource "vcd_nsxt_ip_set" "cloudflare_networks" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_cloudflare_networks == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_CLOUDFLARE"
  description = "IPv4 and 6 CloudFlare Networks"
  ip_addresses = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
    "2400:cb00::/32",
    "2606:4700::/32",
    "2803:f800::/32",
    "2405:b500::/32",
    "2405:8100::/32",
    "2a06:98c0::/29",
    "2c0f:f248::/32",
  ]
}

resource "vcd_nsxt_ip_set" "exchange_online" {

  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_exchange_online_networks == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_O365_EXC_ONLINE"
  description = "IPv4 and 6 Office 365 Networks - https://learn.microsoft.com/en-us/microsoft-365/enterprise/urls-and-ip-address-ranges?view=o365-worldwide"
  ip_addresses = [
    "40.92.0.0/15",
    "40.107.0.0/16",
    "52.100.0.0/14",
    "104.47.0.0/17",
    "2a01:111:f400::/48",
    "2a01:111:f403::/48"
  ]
}


resource "vcd_nsxt_ip_set" "rapid7" {

  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_rapid7_hosts == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_RAPID7_EU"
  description = "IPv4 Rapid 7 Hosts"
  ip_addresses = [
    "3.120.221.108",
    "3.120.196.152"
  ]
}

resource "vcd_nsxt_ip_set" "customer_kms" {

  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_customer_kms == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_customer_KMS"
  description = "IPv4 KMS Server used for Windows Activation TCP/1688"
  ip_addresses = [
    "173.255.144.24/32"
  ]
}

resource "vcd_nsxt_app_port_profile" "kms" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count      = local.create_tenant_ipset_customer_kms == true ? 1 : 0
  org        = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  context_id = module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_id

  name        = "KMS_TCP_1688"
  description = "KMS Activation TCP/1688"

  scope = "TENANT"

  app_port {
    protocol = "TCP"
    port     = ["1688"]
  }
}

resource "vcd_nsxt_ip_set" "quad9_dns" {

  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_quad9_dns == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_QUAD9_DNS"
  description = "IPv4 and 6 Quad 9 DNS Servers - https://quad9.net/"
  ip_addresses = [
    "9.9.9.9",
    "149.112.112.112",
    "2620:fe::fe",
    "2620:fe::9"
  ]
}

resource "vcd_nsxt_ip_set" "nist_ntp" {

  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_ipset_nist_ntp == true ? 1 : 0

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name        = "EXT_NIST_NTP"
  description = "IPv4 and 6 NIST NTP Servers - https://tf.nist.gov/tf-cgi/servers.cgi"
  ip_addresses = [
    "129.6.15.29",
    "129.6.15.30",
    "2610:20:6f15:15::27",
    "132.163.96.2",
    "132.163.96.3",
    "2610:20:6f96:96::4"
  ]
}
# Looks like this resource is an all or nothing, you can only manage the entire rule base
# resource "vcd_nsxt_firewall" "customer_kms" {
#   depends_on = [
#     module.vcloud_tenant_vdc_edge_nsxt_001
#   ]
#   # Added ability to skip the creation on an org based on a local var, as it might not be required
#   count = local.create_tenant_firewall_rule_customer_kms == true ? 1 : 0
# 
#   org             = local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
#   edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id
# 
#     # Rule #1 - Allows in IPv4 traffic from security group `vcd_nsxt_security_group.group1.id`
#   rule {
#     action      = "ALLOW"
#     name        = "OUTBOUND_KMS"
#     direction   = "OUT"
#     ip_protocol = "IPV4"
#     destination_ids = [vcd_nsxt_ip_set.customer_kms[0].id]
#     app_port_profile_ids = [vcd_nsxt_app_port_profile.kms[0].id]
#   }
# }

resource "vcd_nsxt_ip_set" "custom" {
  depends_on = [
    module.vcloud_tenant_vdc_edge_nsxt_001
  ]
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  for_each = {
    for k, v in local.custom_ipsets : k => v if local.create_tenant_ipset_custom == true
  }

  org             = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
  edge_gateway_id = module.vcloud_tenant_vdc_edge_nsxt_001[0].vcd_tenant_vdc_edge_id

  name         = each.key
  description  = "${each.value.description} - ${each.value.ip_addresses[0]}"
  ip_addresses = each.value.ip_addresses
}

resource "vcd_catalog" "tenant" {
  # Added ability to skip the creation on an org based on a local var, as it might not be required
  count = local.create_tenant_catalog == true ? 1 : 0
  org   = local.create_tenant_org == true ? module.vcloud_tenant_org_001[0].vcd_tenant_org_name : local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code

  name             = local.tenant_catalog_name
  description      = "${local.tenant_customer_name} - vCloud Catalog"
  delete_recursive = true
  delete_force     = true
  publish_enabled  = false
  cache_enabled    = false
  password         = null # Required if publishing is enabled.
}

# module "vcloud_tenant_vdc_group_001" {
#   count  = local.create_tenant_edge_nsxt == true ? 1 : 0
#   source = "../../modules/services/vcloud_tenant_vdc_group"

#   tenant_customer_vdc = "${local.customer_customer_prefix}-919-${format("%03d", local.tenant_vdc_instance_number)}"
#   tenant_customer_org = local.override_org_name == true ? local.tenant_org_name : local.tenant_customer_code
#   vcd_tenant_vdc_id   = module.vcloud_tenant_vdc_001[0].vcd_tenant_vdc_id

# }
