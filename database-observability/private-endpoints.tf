# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

resource "oci_database_management_db_management_private_endpoint" "these" {
  for_each = local.dbm_private_endpoint_settings

  compartment_id            = each.value.compartment_id
  name                      = each.value.name
  description               = each.value.description
  subnet_id                 = each.value.subnet_id
  nsg_ids                   = each.value.nsg_ids
  is_cluster                = each.value.is_cluster
  is_dns_resolution_enabled = each.value.is_dns_resolution_enabled
  defined_tags              = each.value.defined_tags
  freeform_tags             = each.value.freeform_tags

  depends_on = [terraform_data.module_contract]
}

resource "oci_opsi_operations_insights_private_endpoint" "these" {
  for_each = local.opsi_private_endpoint_settings

  compartment_id      = each.value.compartment_id
  display_name        = each.value.display_name
  description         = each.value.description
  vcn_id              = each.value.vcn_id
  subnet_id           = each.value.subnet_id
  nsg_ids             = each.value.nsg_ids
  is_used_for_rac_dbs = each.value.is_used_for_rac_dbs
  defined_tags        = each.value.defined_tags
  freeform_tags       = each.value.freeform_tags

  depends_on = [terraform_data.module_contract]
}
