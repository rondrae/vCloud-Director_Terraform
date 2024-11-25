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

#resource "vcd_edgegateway" "tenant-org-vdc01-edge" {
#    org                           = var.tenant_customer_org
#    vdc                           = var.tenant_customer_vdc
#    name                          = var.tenant_customer_edge
#    description                   = local.org_vdc_edge_description
#    external_network {
#        enable_rate_limit         = var.edge_enable_rate_limit
#        incoming_rate_limit       = var.edge_incoming_rate_limit_Mbps
#        name                      = var.provider_external_network_name
#        outgoing_rate_limit       = var.edge_outgoing_rate_limit_Mbps
#
#        subnet {
#            gateway               = var.provider_external_network_gateway
#            netmask               = var.provider_external_network_netmask
#            use_for_default_route = true
#        }
#    }
#
#    configuration                 = var.edge_size
#    ha_enabled                    = var.edge_enable_ha
#    distributed_routing           = var.edge_enable_distributed_routing
#    fw_enabled                    = var.edge_enable_firewall
#    fw_default_rule_action        = var.edge_firewall_default_action
#
#    lb_enabled                    = var.edge_lb_enable
#    lb_acceleration_enabled       = var.edge_acceleration_enable
#}


data "vcd_external_network_v2" "nsxt-ext-net" {
  name = var.provider_external_network_name
}

data "cidr_network" "nsxt-ext-net-netmask" {
  ip   = var.provider_external_network_gateway
  mask = var.provider_external_network_netmask
}

data "vcd_org_vdc" "tenant_customer_vdc" {
  org   = var.tenant_customer_org
  name  = var.tenant_customer_vdc
  count = var.tenant_customer_vdc != null ? 1 : 0
}

# data "vcd_nsxt_edge_cluster" "secondary" {
#   org    = var.tenant_customer_org
#   vdc_id = var.tenant_customer_vdc_id != null ? var.tenant_customer_vdc_id : data.vcd_org_vdc.tenant_customer_vdc[0].id
#   name   = var.provider_edge_cluster_name
# }

resource "vcd_nsxt_edgegateway" "nsxt-edge" {

  org         = var.tenant_customer_org
  owner_id    = var.tenant_customer_vdc_id
  name        = var.tenant_customer_edge
  description = local.org_vdc_edge_description

  starting_vdc_id = var.tenant_customer_vdc_id != null ? var.tenant_customer_vdc_id : data.vcd_org_vdc.tenant_customer_vdc[0].id

  #edge_cluster_id = data.vcd_nsxt_edge_cluster.secondary.id

  external_network_id = data.vcd_external_network_v2.nsxt-ext-net.id
  subnet {
    gateway       = var.provider_external_network_gateway
    prefix_length = data.cidr_network.nsxt-ext-net-netmask.mask_bits
    # primary_ip should fall into defined "allocated_ips" range as otherwise
    # next apply will report additional range of "allocated_ips" with the range
    # containing single "primary_ip" and will cause non-empty plan.
    primary_ip = var.tenant_gateway_external_ip
    allocated_ips {
      #start_address = data.cidr_network.nsxt-ext-net-netmask.first_ip
      start_address = var.tenant_gateway_external_ip
      #end_address   = data.cidr_network.nsxt-ext-net-netmask.last_ip
      #end_address   = var.tenant_gateway_external_end_address != "" ? var.tenant_gateway_external_end_address : var.tenant_gateway_external_ip
      end_address = var.tenant_gateway_external_ip
    }

    dynamic "allocated_ips" {
      for_each = var.tenant_gateway_additional_ip_manual_additional_ips

      content {
        start_address = allocated_ips.value
        end_address   = allocated_ips.value
      }
    }
    #dynamic "subnet_with_ip_count" {
    #  for = var.tenant_gateway_additional_ip_auto_assign_count 
    #
    #  content {
    #    gateway            = var.provider_external_network_gateway
    #    prefix_length      = data.cidr_network.nsxt-ext-net-netmask.mask_bits
    #    allocated_ip_count = var.tenant_gateway_additional_ip_auto_assign_count
    #  }
    #}
  }
  dedicate_external_network = false
}
