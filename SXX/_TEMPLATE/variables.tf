variable "vcd_admin_user" {
  description = "Username used to logon to the provider interface"
  type        = string
  sensitive   = true
  nullable    = false
}
variable "vcd_admin_pass" {
  description = "Password of the user used to logon to the provider interface"
  type        = string
  sensitive   = true
  nullable    = false
}
variable "vcd_admin_org" {
  default = "System"
}
variable "vcd_auth_type" {
  default = "integrated"
}

variable "vcd_max_retry_timeout" {
  default = "2"
}
variable "vcd_allow_unverified_ssl" {
  default = "false"
}

#  Used to map to the other variables
# variable "customer_site_number" {
#   description = "The Internal Number allocated by customer to the Site"
#   type        = string
#   nullable    = false
#   validation {
#     condition = length(var.customer_site_number) == 2
#     error_message = "Site Code should be 2 digits"
#   }
# }

variable "vcd_url" {
  type = map(any)
  default = {
    "01" = "https://pod01/api"
    "05" = "https://pod05/api"
    "10" = "https://pod10/api"
    "11" = "https://pod11/api"
    "12" = "https://pod12/api"
    "17" = "https://pod17/api"
  }
}

variable "vcd_provider_vdc" {
  type = map(any)
  default = {
    "01" = "pVDC_pod01"
    "05" = "pVDC_pod05"
    "10" = "pVDC_pod10"
    "11" = "pVDC_pod11"
    "12" = "pVDC_pod12"
    "17" = "pVDC_pod17"
  }
}

variable "vcd_provider_network_pool" {
  type = map(any)
  default = {
    "01" = "OverlayTZ_pod01"
    "05" = "pVDC_pod05"
    "10" = "OverlayTZ_pod10"
    "11" = "GENEVE_pod11"
    "12" = "GENEVE_pod12"
    "17" = "pVDC_pod17"
  }
}

variable "vcd_provider_external_network_name" {
  type = map(any)
  default = {
    "01" = "INTERNET_pod01"
    "05" = "INTERNET_pod05"
    "10" = "INTERNET_pod10"
    "11" = "INTERNET_pod11"
    "12" = "INTERNET_pod12"
    "17" = "INTERNET_pod17"
  }
}
variable "vcd_provider_external_network_netmask" {
  type = map(any)
  default = {
    "01" = "255.255.255.0"
    "05" = "255.255.255.0"
    "10" = "255.255.255.0"
    "11" = "255.255.254.0"
    "12" = "255.255.255.128"
    "17" = "255.255.255.0"
  }
}

variable "vcd_provider_external_network_gateway" {
  type = map(any)
  default = {
    "01" = "*.*.*.*"
    "05" = "*.*.*.*"
    "10" = "*.*.*.*"
    "11" = "*.*.*.*"
    "12" = "*.*.*.*"
    "17" = "*.*.*.*"
  }
}
#
# ------ START NSX-T NSX-T NSX-T NSX-T
#
variable "vcd_provider_gateway_name" {
  type = map(any)
  default = {
    "01" = "INTERNET_01"
    "05" = "INTERNET_05"
    "10" = "INTERNET_10"
    "11" = "INTERNET_11"
    "12" = "INTERNET_12"
    "17" = "INTERNET_17"
  }
}
variable "vcd_provider_gateway_network_netmask" {
  type = map(any)
  default = {
    "01" = "255.255.255.0"
    "05" = "255.255.255.0"
    "10" = "255.255.255.0"
    "11" = "255.255.254.0"
    "12" = "255.255.255.128"
    "17" = "255.255.255.0"
  }
}

variable "vcd_provider_gateway_network_gateway" {
  type = map(any)
  default = {
    "01" = "0.0.0.0"
    "05" = "0.0.0.0"
    "10" = "0.0.0.0"
    "11" = "0.0.0.0"
    "12" = "0.0.0.0"
    "17" = "0.0.0.0"
  }
}
variable "vcd_provider_edge_cluster_name" {
  type = map(any)
  default = {
    "01" = "EDGE_CLUSTER_01"
    "05" = "EDGE_CLUSTER_05"
    "10" = "EDGE_CLUSTER_10"
    "11" = "EDGE_CLUSTER_11"
    "12" = "EDGE_CLUSTER_12"
    "17" = "EDGE_CLUSTER_17"
  }
}
#
# ------ END NSX-T NSX-T NSX-T NSX-T
#
variable "tenant_vdc_cpu_mhz_speed" {
  type = map(any)
  default = {

    "01" = 2394
    "05" = 2500
    "10" = 2394
    "11" = 2394
    "12" = 2394
    "17" = 2600
  }
}

variable "tenant_vdc_storage_policy" {
  type = map(any)
  default = {
    "01" = "storage_01"
    "05" = "storage_05"
    "10" = "storage_10"
    "11" = "storage_11"
    "12" = "storage_12"
    "17" = "storage_17"
  }
}

variable "quad9_dns1" {
  default = "9.9.9.9"
}
variable "quad9_dns2" {
  default = "149.112.112.112"
}

