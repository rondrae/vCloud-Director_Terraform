variable "tenant_customer_org" {
  description = "This is the customer code"
  type        = string
}
variable "tenant_customer_vdc" {
  description = "This is the customer code"
  type        = string
}
variable "tenant_customer_prefix" {
  description = "This is the customer code"
  type        = string
}
variable "tenant_customer_name" {
  description = "This is the customers full name"
  type        = string
}
variable "customer_site_number" {
  description = "Whats the customer SiteCode"
  type        = string
}
variable "tenant_provider_vdc" {
  type = string
}
variable "tenant_vdc_allocation_model" {
  type = string
  default = "Flex"
}
variable "tenant_vdc_elasticity"{
  type = bool
  default = false
}
variable "tenant_vdc_include_vm_memory_overhead"{
  type = bool
  default = false
}
variable "tenant_vdc_storage_mb_limit" {
  type = number
  description = "This is the amount in MB of how much storage to allocate"
  default = 0
}
variable "tenant_vdc_delete_recursive" {
  description = "If true, when deleting an org will also recursively delete all powered off resources"
  # VMware default is to set this to true
  default     = "true"
}
variable "tenant_vdc_delete_force" {
  description = "If true, when deleting an org resources still powered on will also be deleted"
  # VMware default is to set this to true
  default     = "true"
}
variable "tenant_vdc_memory_guaranteed" {
  default = 0
  type = number
}
variable "tenant_vdc_cpu_guaranteed" {
  default = 0
  type = number
}
variable "tenant_vdc_cpu_mhz_speed" {
  type = number
  default = 1000
}
variable "tenant_vdc_total_cpu_count" {
  type = number
  default = 1
}
variable "tenant_vdc_cpu_buffer_percent" {
  type = number
  default = 1.10
}
variable "tenant_vdc_memory_buffer_percent" {
  type = number
  default = 1.10
}
variable "tenant_vdc_network_quota" {
  type = number
  default = 10
}
variable "tenant_vdc_vm_quota" {
  type = number
  default = 100
}
variable "tenant_vdc_total_memory_gb_ordered" {
  type = number
  default = 1
}
variable "tenant_vdc_is_enabled" {
  type = bool
  default = true
}
variable "tenant_provider_network_pool" {
  type=string
}
# variable "use_default_storage_policy" {
#   type = bool
#   default = false
# }
variable "override_storage_policy" {
  type = bool
  default = false
}
variable "tenant_vdc_storage_policy" {
  type = string
  default = ""
}

variable "provider_default_storage_profile" {
  type = string
  default = "CPOD Default Storage Policy"
}
variable "customer_site_region" {
  type = map
  default = {
    "01" = "GBR-Jersey"
    "05" = "GBR-Guernsey"
    "10" = "GBR-London"
    "11" = "CAN-Toronto"
    "12" = "CAN-Barrie"
    "13" = "LUX-Luxembourg"
    "14" = "LUX-Luxembourg"
    "17" = "IRL-Dublin"
    }
}