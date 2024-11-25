terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.9.0"
    }
    cidr = {
      source  = "volcano-coffee-company/cidr"
      version = "0.1.0"
    }
  }
}

locals {
  org_vdc_edge_description = "${title(var.tenant_customer_name)} Edge Gateway in ${var.customer_site_region["${var.customer_site_number}"]}"
}

resource "vcd_edgegateway" "tenant-org-vdc01-edge" {
  org         = var.tenant_customer_org
  vdc         = var.tenant_customer_vdc
  name        = var.tenant_customer_edge
  description = local.org_vdc_edge_description
  external_network {
    enable_rate_limit   = var.edge_enable_rate_limit
    incoming_rate_limit = var.edge_incoming_rate_limit_Mbps
    name                = var.provider_external_network_name
    outgoing_rate_limit = var.edge_outgoing_rate_limit_Mbps

    subnet {
      gateway               = var.provider_external_network_gateway
      netmask               = var.provider_external_network_netmask
      use_for_default_route = true
    }
  }

  configuration          = var.edge_size
  ha_enabled             = var.edge_enable_ha
  distributed_routing    = var.edge_enable_distributed_routing
  fw_enabled             = var.edge_enable_firewall
  fw_default_rule_action = var.edge_firewall_default_action

  lb_enabled              = var.edge_lb_enable
  lb_acceleration_enabled = var.edge_acceleration_enable
}
