# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

module "database_observability" {
  source = "../.."

  tenancy_ocid                         = var.tenancy_ocid
  database_observability_configuration = var.database_observability_configuration
  compartments_dependency              = var.compartments_dependency
  vcns_dependency                      = var.vcns_dependency
  subnets_dependency                   = var.subnets_dependency
  network_security_groups_dependency   = var.network_security_groups_dependency
  databases_dependency                 = var.databases_dependency
  managed_databases_dependency         = var.managed_databases_dependency
  vault_secrets_dependency             = var.vault_secrets_dependency
  dbm_private_endpoints_dependency     = var.dbm_private_endpoints_dependency
  opsi_private_endpoints_dependency    = var.opsi_private_endpoints_dependency
}

output "database_management" {
  value = module.database_observability.database_management
}

output "database_insights" {
  value = module.database_observability.database_insights
}

output "operation_receipt" {
  value = module.database_observability.operation_receipt
}
