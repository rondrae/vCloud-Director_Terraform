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



resource "vcd_vdc_group" "vdc-group-01" {
  default_policy_status = true
  dfw_enabled           = true
  name                  = var.tenant_customer_vdc
  org                   = var.tenant_customer_org
  participating_vdc_ids = [
    var.vcd_tenant_vdc_id
  ]
  starting_vdc_id = var.vcd_tenant_vdc_id

}

