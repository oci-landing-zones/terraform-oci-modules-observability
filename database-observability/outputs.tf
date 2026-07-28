# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

output "dbm_private_endpoints" {
  description = "Database Management private endpoints created by this module."
  value = var.enable_output ? {
    for key, endpoint in oci_database_management_db_management_private_endpoint.these : key => {
      id             = endpoint.id
      compartment_id = endpoint.compartment_id
      name           = endpoint.name
      subnet_id      = endpoint.subnet_id
    }
  } : null
}

output "opsi_private_endpoints" {
  description = "Operations Insights private endpoints created by this module."
  value = var.enable_output ? {
    for key, endpoint in oci_opsi_operations_insights_private_endpoint.these : key => {
      id             = endpoint.id
      compartment_id = endpoint.compartment_id
      display_name   = endpoint.display_name
      subnet_id      = endpoint.subnet_id
      vcn_id         = endpoint.vcn_id
    }
  } : null
}

output "database_management" {
  description = "Database Management action-resource identifiers by stable target key."
  value = var.enable_output ? merge(
    {
      for key, resource in oci_database_management_database_dbm_features_management.cdb : key => {
        id            = resource.id
        database_type = "CDB"
      }
    },
    {
      for key, resource in oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management.pdb : key => {
        id            = resource.id
        database_type = "PDB"
      }
    },
    {
      for key, resource in oci_database_management_database_dbm_features_management.non_cdb : key => {
        id            = resource.id
        database_type = "NON_CDB"
      }
    },
  ) : null
}

output "database_insights" {
  description = "Operations Insights identifiers by stable target key."
  value = var.enable_output ? {
    for key, insight in oci_opsi_database_insight.these : key => {
      id             = insight.id
      compartment_id = insight.compartment_id
    }
  } : null
}

output "operation_receipt" {
  description = "Non-secret operation metadata. It is an audit aid, never authorization for the next stage."
  value = var.enable_output ? {
    lifecycle_id                     = local.configuration.lifecycle_id
    operation_stage                  = local.operation_stage
    database_keys                    = sort(keys(local.database_targets))
    authoritative_observation_source = local.operation_stage == "DISABLE_CDB" ? "oracle/oci managed_database data source" : null
    next_required_stage              = local.operation_stage == "DISABLE_TARGETS" && length(local.pdb_targets) > 0 ? "DISABLE_CDB after a new reviewed plan verifies every PDB is disabled" : null
  } : null
}
