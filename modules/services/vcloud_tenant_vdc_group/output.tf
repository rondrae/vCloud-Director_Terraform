output "vcd_tenant_vdc_group_id" {
  value = vcd_vdc_group.vdc-group-01.id
}
output "vcd_tenant_vdc_group_name" {
  value = vcd_vdc_group.vdc-group-01.name
}

output "vcd_tenant_vdc_group_starting_name" {
  value = vcd_vdc_group.vdc-group-01.starting_vdc_id
}
