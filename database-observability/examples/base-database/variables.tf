# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

variable "region" {
  description = "OCI region. Authentication is inherited from the execution environment."
  type        = string
}

variable "tenancy_ocid" {
  description = "Required only when TENANCY-ROOT is used as a compartment reference."
  type        = string
  default     = null
  nullable    = true
}

variable "database_observability_configuration" {
  description = "Configuration passed unchanged to the database-observability module."
  type        = any
}

variable "compartments_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "vcns_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "subnets_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "network_security_groups_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "databases_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "managed_databases_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "vault_secrets_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "dbm_private_endpoints_dependency" {
  type    = map(object({ id = string }))
  default = {}
}

variable "opsi_private_endpoints_dependency" {
  type    = map(object({ id = string }))
  default = {}
}
