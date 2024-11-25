terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.9.0"
    }
  }
}

resource "vcd_org" "tenant-org" {
  name                 = trimspace(upper(var.tenant_customer_org))
  full_name            = title(var.tenant_customer_name)
  description          = "${title(var.tenant_customer_name)} vCloud Org in ${var.customer_site_region["${var.customer_site_number}"]}"
  is_enabled           = var.tenant_org_is_enabled
  delete_recursive     = var.tenant_org_delete_recursive
  delete_force         = var.tenant_org_delete_force
  deployed_vm_quota    = var.tenant_org_deployed_vm_quota
  stored_vm_quota      = var.tenant_org_stored_vm_quota
  can_publish_catalogs = var.tenant_org_can_publish_catalogs
  vapp_lease {
    maximum_runtime_lease_in_sec          = 0
    power_off_on_runtime_lease_expiration = false
    maximum_storage_lease_in_sec          = 0
    delete_on_storage_lease_expiration    = false
  }
  vapp_template_lease {
    maximum_storage_lease_in_sec       = 0
    delete_on_storage_lease_expiration = false
  }
}
