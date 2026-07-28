# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

variable "tenancy_ocid" {
  description = "Tenancy OCID. Required only when TENANCY-ROOT is used as a compartment reference."
  type        = string
  default     = null
  nullable    = true
}

variable "database_observability_configuration" {
  description = "Database Management and Operations Insights configuration. Every value ending in _id can be a literal OCID or a key in the matching dependency map."
  type = object({
    default_compartment_id = string
    default_defined_tags   = optional(map(string), {})
    default_freeform_tags  = optional(map(string), {})
    lifecycle_id           = string
    operation_stage        = optional(string, "ENABLE")
    dbm_private_endpoints = optional(map(object({
      compartment_id            = optional(string)
      name                      = string
      description               = optional(string)
      subnet_id                 = string
      nsg_ids                   = optional(set(string), [])
      is_cluster                = optional(bool, false)
      is_dns_resolution_enabled = optional(bool, true)
      defined_tags              = optional(map(string), {})
      freeform_tags             = optional(map(string), {})
    })), {})
    opsi_private_endpoints = optional(map(object({
      compartment_id      = optional(string)
      display_name        = string
      description         = optional(string)
      vcn_id              = string
      subnet_id           = string
      nsg_ids             = optional(set(string), [])
      is_used_for_rac_dbs = optional(bool, false)
      defined_tags        = optional(map(string), {})
      freeform_tags       = optional(map(string), {})
    })), {})
    databases = map(object({
      compartment_id             = optional(string)
      database_id                = string
      database_type              = string
      parent_database_key        = optional(string)
      managed_database_id        = optional(string)
      dbm_private_endpoint_id    = string
      opsi_private_endpoint_id   = optional(string)
      enable_operations_insights = optional(bool, false)
      management_type            = optional(string, "ADVANCED")
      service_name               = string
      password_secret_id         = string
      ssl_secret_id              = optional(string)
      monitoring_user            = optional(string, "DBSNMP")
      role                       = optional(string, "NORMAL")
      protocol                   = optional(string, "TCP")
      port                       = optional(number, 1521)
      defined_tags               = optional(map(string), {})
      freeform_tags              = optional(map(string), {})
    }))
  })

  validation {
    condition     = contains(["ENABLE", "DISABLE_TARGETS", "DISABLE_CDB"], upper(var.database_observability_configuration.operation_stage))
    error_message = "operation_stage must be ENABLE, DISABLE_TARGETS, or DISABLE_CDB."
  }

  validation {
    condition = (
      length(var.database_observability_configuration.lifecycle_id) >= 8 &&
      length(var.database_observability_configuration.lifecycle_id) <= 64 &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9_.-]+$", var.database_observability_configuration.lifecycle_id))
    )
    error_message = "lifecycle_id must be 8-64 characters and contain only letters, numbers, dots, underscores, and hyphens."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      contains(["CDB", "PDB", "NON_CDB"], upper(target.database_type))
    ])
    error_message = "database_type must be CDB, PDB, or NON_CDB."
  }

  validation {
    condition = alltrue([
      for key, target in var.database_observability_configuration.databases :
      upper(target.database_type) != "PDB" || (
        try(trimspace(target.parent_database_key), "") != "" &&
        contains(keys(var.database_observability_configuration.databases), target.parent_database_key) &&
        upper(try(var.database_observability_configuration.databases[target.parent_database_key].database_type, "")) == "CDB" &&
        upper(try(var.database_observability_configuration.databases[target.parent_database_key].management_type, "")) == "ADVANCED"
      )
    ])
    error_message = "Every PDB must reference an ADVANCED CDB in the same databases map through parent_database_key."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      upper(target.database_type) == "PDB" || try(trimspace(target.parent_database_key), "") == ""
    ])
    error_message = "Only PDB targets may set parent_database_key."
  }

  validation {
    condition = (
      upper(var.database_observability_configuration.operation_stage) != "DISABLE_CDB" ||
      alltrue([
        for target in values(var.database_observability_configuration.databases) :
        upper(target.database_type) != "PDB" || try(trimspace(target.managed_database_id), "") != ""
      ])
    )
    error_message = "DISABLE_CDB requires managed_database_id for every PDB so current DBM feature state can be read authoritatively."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      trimspace(target.database_id) != "" &&
      trimspace(target.dbm_private_endpoint_id) != "" &&
      trimspace(target.service_name) != "" &&
      trimspace(target.password_secret_id) != "" &&
      trimspace(target.monitoring_user) != ""
    ])
    error_message = "Every database requires database_id, dbm_private_endpoint_id, service_name, password_secret_id, and monitoring_user."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      !target.enable_operations_insights || try(trimspace(target.opsi_private_endpoint_id), "") != ""
    ])
    error_message = "enable_operations_insights=true requires opsi_private_endpoint_id."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      contains(["BASIC", "ADVANCED"], upper(target.management_type))
    ])
    error_message = "management_type must be BASIC or ADVANCED."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      contains(["NORMAL", "SYSDBA", "SYSOPER", "SYSASM"], upper(target.role))
    ])
    error_message = "role must be NORMAL, SYSDBA, SYSOPER, or SYSASM."
  }

  validation {
    condition = alltrue([
      for target in values(var.database_observability_configuration.databases) :
      contains(["TCP", "TCPS"], upper(target.protocol)) &&
      target.port >= 1 &&
      target.port <= 65535 &&
      (upper(target.protocol) != "TCPS" || try(trimspace(target.ssl_secret_id), "") != "")
    ])
    error_message = "protocol must be TCP or TCPS, port must be 1-65535, and TCPS requires ssl_secret_id."
  }
}

variable "compartments_dependency" {
  description = "Externally managed compartments keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "vcns_dependency" {
  description = "Externally managed VCNs keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "subnets_dependency" {
  description = "Externally managed subnets keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "network_security_groups_dependency" {
  description = "Externally managed network security groups keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "databases_dependency" {
  description = "Externally managed cloud databases and pluggable databases keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "managed_databases_dependency" {
  description = "Database Management managed-database identities keyed by Landing Zone reference. Used for fail-closed CDB disable verification."
  type        = map(object({ id = string }))
  default     = {}
}

variable "vault_secrets_dependency" {
  description = "Externally managed Vault secrets keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "dbm_private_endpoints_dependency" {
  description = "Externally managed Database Management private endpoints keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "opsi_private_endpoints_dependency" {
  description = "Externally managed Operations Insights private endpoints keyed by Landing Zone reference."
  type        = map(object({ id = string }))
  default     = {}
}

variable "enable_output" {
  description = "Whether Terraform should expose module outputs."
  type        = bool
  default     = true
}

variable "module_name" {
  description = "The module name used in Landing Zone ownership tags."
  type        = string
  default     = "database-observability"
}
