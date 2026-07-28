# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

resource "terraform_data" "module_contract" {
  input = {
    database_keys   = sort(keys(local.configuration.databases))
    lifecycle_id    = local.configuration.lifecycle_id
    operation_stage = local.operation_stage
  }

  lifecycle {
    precondition {
      condition     = local.configuration.default_compartment_id != "TENANCY-ROOT" || var.tenancy_ocid != null
      error_message = "tenancy_ocid is required when default_compartment_id is TENANCY-ROOT."
    }

    precondition {
      condition     = length(local.configuration.databases) > 0
      error_message = "database_observability_configuration.databases must contain at least one reviewed target."
    }

  }
}

# The second CDB-disable apply reads current provider-backed state for every PDB.
# A copied local receipt is neither accepted nor needed.
data "oci_database_management_managed_database" "pdb_disable_observation" {
  for_each = local.operation_stage == "DISABLE_CDB" ? local.pdb_targets : {}

  managed_database_id = each.value.managed_database_id
}

resource "terraform_data" "pdb_disable_observation" {
  count = local.operation_stage == "DISABLE_CDB" ? 1 : 0

  input = {
    observer        = "oracle/oci managed_database data source"
    pdb_target_keys = sort(keys(local.pdb_targets))
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for observed in values(data.oci_database_management_managed_database.pdb_disable_observation) :
        alltrue([
          for feature in observed.dbmgmt_feature_configs :
          upper(feature.feature) != "DIAGNOSTICS_AND_MANAGEMENT" ||
          contains(["DISABLED", "NOT_ENABLED"], upper(feature.feature_status))
        ])
      ])
      error_message = "DISABLE_CDB requires every observed PDB DIAGNOSTICS_AND_MANAGEMENT feature to be absent, DISABLED, or NOT_ENABLED."
    }
  }
}

resource "oci_database_management_database_dbm_features_management" "cdb" {
  for_each = local.cdb_targets

  database_id                 = each.value.database_id
  enable_database_dbm_feature = local.operation_stage != "DISABLE_CDB"
  can_disable_all_pdbs        = false

  feature_details {
    feature                           = "DIAGNOSTICS_AND_MANAGEMENT"
    management_type                   = each.value.management_type
    can_enable_all_current_pdbs       = false
    is_auto_enable_pluggable_database = false

    connector_details {
      connector_type       = "PE"
      private_end_point_id = each.value.dbm_private_endpoint_id
    }

    database_connection_details {
      connection_credentials {
        credential_type    = each.value.ssl_secret_id != null ? "SSL_DETAILS" : "DETAILS"
        user_name          = each.value.monitoring_user
        password_secret_id = each.value.password_secret_id
        ssl_secret_id      = each.value.ssl_secret_id
        role               = each.value.role
      }

      connection_string {
        connection_type = "BASIC"
        port            = each.value.port
        protocol        = each.value.protocol
        service         = each.value.service_name
      }
    }
  }

  depends_on = [
    terraform_data.module_contract,
    terraform_data.pdb_disable_observation,
  ]
}

resource "oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management" "pdb" {
  for_each = local.pdb_targets

  pluggable_database_id                 = each.value.database_id
  enable_pluggable_database_dbm_feature = local.operation_stage == "ENABLE"

  feature_details {
    feature                           = "DIAGNOSTICS_AND_MANAGEMENT"
    management_type                   = each.value.management_type
    can_enable_all_current_pdbs       = false
    is_auto_enable_pluggable_database = false

    connector_details {
      connector_type       = "PE"
      private_end_point_id = each.value.dbm_private_endpoint_id
    }

    database_connection_details {
      connection_credentials {
        credential_type    = each.value.ssl_secret_id != null ? "SSL_DETAILS" : "DETAILS"
        user_name          = each.value.monitoring_user
        password_secret_id = each.value.password_secret_id
        ssl_secret_id      = each.value.ssl_secret_id
        role               = each.value.role
      }

      connection_string {
        connection_type = "BASIC"
        port            = each.value.port
        protocol        = each.value.protocol
        service         = each.value.service_name
      }
    }
  }

  depends_on = [oci_database_management_database_dbm_features_management.cdb]
}

resource "oci_database_management_database_dbm_features_management" "non_cdb" {
  for_each = local.non_cdb_targets

  database_id                 = each.value.database_id
  enable_database_dbm_feature = local.operation_stage == "ENABLE"
  can_disable_all_pdbs        = false

  feature_details {
    feature                           = "DIAGNOSTICS_AND_MANAGEMENT"
    management_type                   = each.value.management_type
    can_enable_all_current_pdbs       = false
    is_auto_enable_pluggable_database = false

    connector_details {
      connector_type       = "PE"
      private_end_point_id = each.value.dbm_private_endpoint_id
    }

    database_connection_details {
      connection_credentials {
        credential_type    = each.value.ssl_secret_id != null ? "SSL_DETAILS" : "DETAILS"
        user_name          = each.value.monitoring_user
        password_secret_id = each.value.password_secret_id
        ssl_secret_id      = each.value.ssl_secret_id
        role               = each.value.role
      }

      connection_string {
        connection_type = "BASIC"
        port            = each.value.port
        protocol        = each.value.protocol
        service         = each.value.service_name
      }
    }
  }

  depends_on = [terraform_data.module_contract]
}

resource "oci_opsi_database_insight" "these" {
  for_each = local.opsi_targets

  compartment_id           = each.value.compartment_id
  entity_source            = "PE_COMANAGED_DATABASE"
  database_id              = each.value.database_id
  database_resource_type   = each.value.database_type == "PDB" ? "pluggabledatabase" : "database"
  dbm_private_endpoint_id  = each.value.dbm_private_endpoint_id
  opsi_private_endpoint_id = each.value.opsi_private_endpoint_id
  defined_tags             = each.value.defined_tags
  freeform_tags            = each.value.freeform_tags

  credential_details {
    credential_type    = "CREDENTIALS_BY_VAULT"
    user_name          = each.value.monitoring_user
    role               = each.value.role
    password_secret_id = each.value.password_secret_id
    wallet_secret_id   = each.value.ssl_secret_id
  }

  depends_on = [
    oci_database_management_database_dbm_features_management.cdb,
    oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management.pdb,
    oci_database_management_database_dbm_features_management.non_cdb,
  ]
}
