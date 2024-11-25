# vCloud Director Tenant Setup

This repo is used to help setup customers in vCloud Director.

it's based on terraform, you will need this installed.

Repo Tested with version `1.4.6`

Please don't pin this version, please try keep up, if a newer version works then bump this readme.

## Download Terraform

https://developer.hashicorp.com/terraform/downloads?product_intent=terraform

## Assumptions

** You will need provider level access to the vCloud instance ** 
** You will need line of sight the vcloud interface/api, can you open the portal? **

# Usage

You will use the template to provision various components, all components are by default disabled, you will pick what you need for the tenant.

For example, the customer already has an org, in which case just create vdc

## Pick'N Mix

Controlling what is configured
```
  #
  # Control the deployment options
  #
  create_tenant_org                            = false
  create_tenant_vdc                            = false
  create_tenant_edge_nsxt                      = false
  enable_tenant_edge_nsxt_alb                  = false
  create_tenant_edge_nsxv                      = false
  create_tenant_vdc_external_network           = false
  create_tenant_vdc_isolated_networks          = false
  create_tenant_vdc_routed_networks            = false
  create_tenant_vdc_routed_networks_snats      = false
  create_tenant_ipset_isolated_networks        = false
  create_tenant_ipset_routed_networks          = false
  create_tenant_ipset_cloudflare_networks      = false
  create_tenant_ipset_exchange_online_networks = false
  create_tenant_ipset_rapid7_hosts             = false
  create_tenant_ipset_customer_kms              = false
  create_tenant_ipset_quad9_dns                = false
  create_tenant_ipset_nist_ntp                 = false
  create_tenant_ipset_custom                   = false
  create_tenant_catalog                        = false
```
^^^ The above example is from the current template, the components are toggled using `true`/`false`

## Copy the template to the a new folder

Copy ``SXX\_TEMPLATE` to `SXX\<SITECODE>_<CUSTOMER ORG>`   << The name of the folder is not important but it will help keep track of the setup. if you happen to want another VDC for an existing customer I would add the VDC to the new folder ie `SXX\<SITECODE>_<CUSTOMER ORG>_<VDC NAME>`

## Customise the main.tf file

edit `SXX\<SITECODE>_<CUSTOMER ORG>\main.tf`

```
locals {
  # Change Per Tenant
  customer_site_number                                  = 0 # Just the number no need to add the s
  tenant_customer_code                                 = ""
  tenant_customer_name                                 = ""
  tenant_vdc_total_cpu_count                           = 0
  tenant_vdc_total_memory_gb_ordered                   = 0
  tenant_vdc_storage_mb_limit                          = 0 * 1024 # This value needs to in MB 1024 = 1024MB = 1GB
  tenant_vdc_instance_number                           = 001
  tenant_edge_nsxt_instance_number                     = 001
  tenant_edge_nsxt_external_ip                         = ""                      # The Primary External IP You have to declare it, sorry ie "z.z.z.z"
  tenant_edge_nsxt_additional_ip_auto_assign           = false                                  # true = auto assign, false = manual
  tenant_edge_nsxt_additional_ip_auto_assign_count     = 1                                      # The number of IPs to allocate only if auto assign is true
  tenant_edge_nsxt_additional_ip_manual_additional_ips = [] # Create a list of additional IPs to allocate ie ["x.x.x.x","y.y.y.y"] only if auto assign is false
  tenant_edge_nsxt_alb_feature_set                     = "STANDARD"                             # Either "STANDARD" or PREMIUM
  tenant_edge_nsxt_alb_enable_transparent_mode         = false                                  # Either True/False, used to expose client IP to virtual server
  tenant_edge_nsxt_alb_service_network                 = "192.168.255.1/25"
  tenant_edge_nsxv_instance_number                     = 1
  ```
### Minimum
`customer_site_number` = Site Number you want to deploy to
`tenant_customer_code` = Customer Code UPPERcase just 2digit number ie DRE01
`tenant_customer_name` = Customer Name, free text field but should be how customers name
`tenant_vdc_total_cpu_count` = How many vCPU's can the customer use?
`tenant_vdc_total_memory_gb_ordered` = How much RAM can the customer use?
`tenant_vdc_storage_mb_limit` = The storage limit in MB!! `n * 1024` can be used if you know the GB amount, if you know MB then delete `* 1024` and just put number

### Only if required
`tenant_vdc_instance_number` = If the customer already has a VDC then use this to customise the number used for the new one.
`tenant_edge_nsxt_instance_number` = If the customer already has an edge then use this to customise the number used for the new one

# Customise the deployment options

Pick the action you would like to perform

ie.
```
  create_tenant_org                            = true
  create_tenant_vdc                            = true
```
^^^ Create a new org and new vdc

# Deploy

from a shell
`cd terraform_vcd_tenant_setup\SXX\<SITE_CODE>_<CUSTOMER_ORG>`

`terraform init`

```
Initializing the backend...
Initializing modules...
- vcloud_tenant_org_001 in ..\..\modules\services\vcloud_tenant_org
- vcloud_tenant_vdc_001 in ..\..\modules\services\vcloud_tenant_vdc
- vcloud_tenant_vdc_edge_nsxt_001 in ..\..\modules\services\vcloud_tenant_vdc_edge_nsxt
- vcloud_tenant_vdc_edge_nsxv_001 in ..\..\modules\services\vcloud_tenant_vdc_edge

Initializing provider plugins...
- Finding vmware/vcd versions matching "3.9.0"...
- Finding volcano-coffee-company/cidr versions matching "0.1.0"...
- Installing vmware/vcd v3.9.0...
- Installed vmware/vcd v3.9.0 (signed by a HashiCorp partner, key ID 8BF53DB49CDB70B0)
- Installing volcano-coffee-company/cidr v0.1.0...
- Installed volcano-coffee-company/cidr v0.1.0 (self-signed, key ID EC2E254A2DEA2F16)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Set your access credentials
`$ENV:TF_VAR_vcd_admin_user='<YOUR USERID>'
`$ENV:TF_VAR_vcd_admin_pass='<YOUR PASSWORD>'

`terraform plan`

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.vcloud_tenant_org_001[0].vcd_org.tenant-org will be created
  + resource "vcd_org" "tenant-org" {
      + can_publish_catalogs            = false
      + can_publish_external_catalogs   = false
      + can_subscribe_external_catalogs = false
      + delete_force                    = true
      + delete_recursive                = true
      + deployed_vm_quota               = 0
      + description                     = "Rondrae vCloud Org in CAN-Toronto"
      + full_name                       = "Rondrae Inc"
      + id                              = (known after apply)
      + is_enabled                      = true
      + metadata                        = (known after apply)
      + name                            = "RON01"
      + stored_vm_quota                 = 0

      + vapp_lease {
          + delete_on_storage_lease_expiration    = false
          + maximum_runtime_lease_in_sec          = 0
          + maximum_storage_lease_in_sec          = 0
          + power_off_on_runtime_lease_expiration = false
        }

      + vapp_template_lease {
          + delete_on_storage_lease_expiration = false
          + maximum_storage_lease_in_sec       = 0
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
^^^ check output, only creating what I expected, not destroying anything, name and discription correct?
if so apply, __don't proceed if not correct !!!__


`terraform apply`

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.vcloud_tenant_org_001[0].vcd_org.tenant-org will be created
  + resource "vcd_org" "tenant-org" {
      + can_publish_catalogs            = false
      + can_publish_external_catalogs   = false
      + can_subscribe_external_catalogs = false
      + delete_force                    = true
      + delete_recursive                = true
      + deployed_vm_quota               = 0
      + description                     = "Rondrae vCloud Org in CAN-Toronto"
      + full_name                       = "Rondrae Inc"
      + id                              = (known after apply)
      + is_enabled                      = true
      + metadata                        = (known after apply)
      + name                            = "RON01"
      + stored_vm_quota                 = 0

      + vapp_lease {
          + delete_on_storage_lease_expiration    = false
          + maximum_runtime_lease_in_sec          = 0
          + maximum_storage_lease_in_sec          = 0
          + power_off_on_runtime_lease_expiration = false
        }

      + vapp_template_lease {
          + delete_on_storage_lease_expiration = false
          + maximum_storage_lease_in_sec       = 0
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vcloud_tenant_org_001[0].vcd_org.tenant-org: Creating...
module.vcloud_tenant_org_001[0].vcd_org.tenant-org: Creation complete after 6s [id=urn:vcloud:org:1a8b9d4d-48fd-446b-98c2-862a83701f62]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
^^^ Action complete and solution delivered

## Optional Extras
These can used to create isolated routed networks and ipsets.

isolated_networks = {
    # "ISOLATED_EXAMPLE_001" = { cidr = "192.168.99.0/24", gw_octet = 1, pool = "192.168.99.5-192.168.99.250", description = "Isolated Backend LAN", dns1 = "9.9.9.9", dns2 = var.quad9_dns2 }
  }

  routed_networks = {
    #"ROUTED_EXAMPLE_001" = { cidr = "192.168.98.0/24", gw_octet = 1, pool = "192.168.98.5-192.168.98.250", description = "Routed Backend LAN", dns1 = var.quad9_dns1, dns2 = var.quad9_dns2, create_snat = true, external_ip = local.tenant_edge_nsxt_external_ip }
  }

  custom_ipsets = {
    #"IPSET_EXAMPLE_001" = { description = "Custom IPSET 001 ", ip_addresses = ["1.1.1.1","2.2.2.2"] }
  }
