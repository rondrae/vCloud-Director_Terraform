# variable "tenant_customer_code" {
#   description = "This is the customer code from viaje"
#   type        = string
# }
variable "tenant_customer_org" {
  description = "This is the customers vcd org name"
  type        = string
}

variable "tenant_customer_name" {
  description = "This is the customers full name"
  type        = string
}
variable "tenant_org_is_enabled" {
  description = "If true, the customers vorg is enabled"
  default     = "true"
}
variable "tenant_org_delete_recursive" {
  description = "If true, when deleting an org will also recursively delete all powered off resources"
  # VMware default is to set this to true
  default     = "true"
}
variable "tenant_org_delete_force" {
  description = "If true, when deleting an org resources still powered on will also be deleted"
  # VMware default is to set this to true
  default     = "true"
}
variable "tenant_org_deployed_vm_quota" {
  description = "Maximum number of virtual machines that can be deployed simultaneously by a member of this organization. VMware Default is unlimited (0)"
  default = 0
}
variable "tenant_org_stored_vm_quota" {
  description = "Maximum number of virtual machines in vApps or vApp templates that can be stored in an undeployed state by a member of this organization. VMware Default is unlimited (0)"
  default = 0
}
variable "tenant_org_can_publish_catalogs" {
  description = "Can the tenant publish their own catalogs. VMware Default is true"
  default = false
}
variable "customer_site_number" {
  description = "Whats the Customer SiteCode"
  type        = string
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