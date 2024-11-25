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
  org_cpu_limit = ceil((var.tenant_vdc_total_cpu_count * var.tenant_vdc_cpu_mhz_speed) * var.tenant_vdc_cpu_buffer_percent)
  # This needs to be a whole number, rounding up using ceil
  org_mem_limit = ceil((var.tenant_vdc_total_memory_gb_ordered * 1024) * var.tenant_vdc_memory_buffer_percent)
  # will this vdc use the pod provided storage policy? probably not they should be using their own.
  # I added this to allow me to provision a vdc when the policy doesn't exist otherwise it will fail.
  org_storage_policy  = var.tenant_vdc_storage_policy
  org_vdc_description = "${title(var.tenant_customer_name)} Virtual DC in ${var.customer_site_region["${var.customer_site_number}"]}"
}

resource "vcd_org_vdc" "tenant-org-vdc01" {
  org               = var.tenant_customer_org
  name              = var.tenant_customer_vdc
  description       = local.org_vdc_description
  provider_vdc_name = var.tenant_provider_vdc
  allocation_model  = var.tenant_vdc_allocation_model
  compute_capacity {
    cpu {
      allocated = 0
      limit     = local.org_cpu_limit
    }
    memory {
      allocated = 0
      limit     = local.org_mem_limit
    }
  }
  network_quota     = var.tenant_vdc_network_quota
  network_pool_name = var.tenant_provider_network_pool
  vm_quota          = var.tenant_vdc_vm_quota
  enabled           = var.tenant_vdc_is_enabled

  storage_profile {
    name    = local.org_storage_policy
    limit   = var.tenant_vdc_storage_mb_limit
    default = true
  }

  memory_guaranteed          = var.tenant_vdc_memory_guaranteed
  cpu_guaranteed             = var.tenant_vdc_cpu_guaranteed
  cpu_speed                  = var.tenant_vdc_cpu_mhz_speed
  elasticity                 = var.tenant_vdc_elasticity
  include_vm_memory_overhead = var.tenant_vdc_include_vm_memory_overhead
  delete_recursive           = var.tenant_vdc_delete_recursive
  delete_force               = var.tenant_vdc_delete_force
}
