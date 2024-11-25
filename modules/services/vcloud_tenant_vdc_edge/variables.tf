variable "tenant_customer_org" {
  description = "This is the customer code"
  type        = string
}
variable "tenant_customer_vdc" {
  description = "This is the customer code"
  type        = string
}
variable "tenant_customer_edge" {
  description = "This is the customer edge within the VDC"
  type        = string
}
variable "tenant_customer_name" {
  description = "This is the customers full name"
  type        = string
}
variable "edge_size" {
  type = string
  default = "full"
}
variable "provider_external_network_name" {
  type = string
}
variable "provider_external_network_netmask" {
  type = string
}
variable "provider_external_network_gateway" {
  type = string
}
variable "edge_enable_rate_limit" {
  type = bool
}
variable "edge_incoming_rate_limit_Mbps" {
  type = number
  default = 0
}

variable "edge_outgoing_rate_limit_Mbps" {
  type = number
  default = 0
}
variable "customer_site_number" {
  description = "Whats the customer SiteCode"
  type        = string
}
variable "customer_site_region" {
  type = map
  default = {
    "01" = "GBR-Jersey"
    "05" = "GBR-Guernsey"
    "10" = "GBR-London"
    "12" = "CAN-Barrie"
    "13" = "LUX-Luxembourg"
    "14" = "LUX-Luxembourg"
    "17" = "IRL-Dublin"
    }
}

variable "edge_enable_ha" {
  type = bool
  default = true
}
variable "edge_enable_distributed_routing" {
  type = bool
  default = true
}
variable "edge_enable_firewall" {
  type = bool
  default = true
}
variable "edge_firewall_default_action" {
  type = string
  default = "deny"
}
variable "edge_lb_enable" {
  type = bool
  default = false
}
variable "edge_acceleration_enable" {
  type = bool
  default = false
}