# Introduction 
Terraform Module for creating an org within vCloud director

This is based on the naming standards

```
locals {
  # Change Per Tenant 
  tenant_customer_code                = "RON01"
  tenant_customer_name                = "Rondrae Limited"
}

# This module will create the tenant organization within vlcoud
module "vcloud_tenant_org_001" {
  # TODO: For source I will need to be updated to reflect source control
  source                             = "../../modules/services/vcloud_tenant_org"
  tenant_customer_org                = local.tenant_customer_code           # customer code i.e. RON01
  tenant_customer_name               = local.tenant_customer_name           # customer full name i.e. Rondrae Limited
  customer_site_number                = var.customer_site_number
}
```