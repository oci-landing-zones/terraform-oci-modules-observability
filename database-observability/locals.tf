# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

locals {
  configuration   = var.database_observability_configuration
  operation_stage = upper(local.configuration.operation_stage)

  default_compartment_id = (
    local.configuration.default_compartment_id == "TENANCY-ROOT"
    ? var.tenancy_ocid
    : try(
      var.compartments_dependency[local.configuration.default_compartment_id].id,
      local.configuration.default_compartment_id,
    )
  )

  default_defined_tags  = local.configuration.default_defined_tags
  default_freeform_tags = local.configuration.default_freeform_tags
  ownership_tags = merge(
    local.default_freeform_tags,
    local.module_tags,
    {
      "db-observability-lifecycle-id" = local.configuration.lifecycle_id
      "db-observability-managed-by"   = "terraform"
    },
  )

  dbm_private_endpoint_settings = {
    for key, endpoint in local.configuration.dbm_private_endpoints : key => merge(endpoint, {
      compartment_id = try(
        var.compartments_dependency[endpoint.compartment_id].id,
        endpoint.compartment_id != null ? endpoint.compartment_id : local.default_compartment_id,
      )
      subnet_id = try(var.subnets_dependency[endpoint.subnet_id].id, endpoint.subnet_id)
      nsg_ids = [
        for nsg_id in endpoint.nsg_ids :
        try(var.network_security_groups_dependency[nsg_id].id, nsg_id)
      ]
      defined_tags  = merge(local.default_defined_tags, endpoint.defined_tags)
      freeform_tags = merge(local.ownership_tags, endpoint.freeform_tags)
    })
  }

  opsi_private_endpoint_settings = {
    for key, endpoint in local.configuration.opsi_private_endpoints : key => merge(endpoint, {
      compartment_id = try(
        var.compartments_dependency[endpoint.compartment_id].id,
        endpoint.compartment_id != null ? endpoint.compartment_id : local.default_compartment_id,
      )
      vcn_id    = try(var.vcns_dependency[endpoint.vcn_id].id, endpoint.vcn_id)
      subnet_id = try(var.subnets_dependency[endpoint.subnet_id].id, endpoint.subnet_id)
      nsg_ids = [
        for nsg_id in endpoint.nsg_ids :
        try(var.network_security_groups_dependency[nsg_id].id, nsg_id)
      ]
      defined_tags  = merge(local.default_defined_tags, endpoint.defined_tags)
      freeform_tags = merge(local.ownership_tags, endpoint.freeform_tags)
    })
  }
}

locals {
  database_targets = {
    for key, target in local.configuration.databases : key => merge(target, {
      database_type = upper(target.database_type)
      compartment_id = try(
        var.compartments_dependency[target.compartment_id].id,
        target.compartment_id != null ? target.compartment_id : local.default_compartment_id,
      )
      database_id = try(var.databases_dependency[target.database_id].id, target.database_id)
      managed_database_id = (
        target.managed_database_id != null
        ? try(var.managed_databases_dependency[target.managed_database_id].id, target.managed_database_id)
        : null
      )
      dbm_private_endpoint_id = try(
        oci_database_management_db_management_private_endpoint.these[target.dbm_private_endpoint_id].id,
        var.dbm_private_endpoints_dependency[target.dbm_private_endpoint_id].id,
        target.dbm_private_endpoint_id,
      )
      opsi_private_endpoint_id = (
        target.opsi_private_endpoint_id != null
        ? try(
          oci_opsi_operations_insights_private_endpoint.these[target.opsi_private_endpoint_id].id,
          var.opsi_private_endpoints_dependency[target.opsi_private_endpoint_id].id,
          target.opsi_private_endpoint_id,
        )
        : null
      )
      password_secret_id = try(
        var.vault_secrets_dependency[target.password_secret_id].id,
        target.password_secret_id,
      )
      ssl_secret_id = (
        target.ssl_secret_id != null
        ? try(var.vault_secrets_dependency[target.ssl_secret_id].id, target.ssl_secret_id)
        : null
      )
      defined_tags  = merge(local.default_defined_tags, target.defined_tags)
      freeform_tags = merge(local.ownership_tags, target.freeform_tags)
    })
  }

  cdb_targets = {
    for key, target in local.database_targets : key => target
    if target.database_type == "CDB"
  }

  pdb_targets = {
    for key, target in local.database_targets : key => target
    if target.database_type == "PDB"
  }

  non_cdb_targets = {
    for key, target in local.database_targets : key => target
    if target.database_type == "NON_CDB"
  }

  opsi_targets = {
    for key, target in local.database_targets : key => target
    if local.operation_stage == "ENABLE" && target.enable_operations_insights
  }
}
