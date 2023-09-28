# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "logging_configuration" {
  description = "Logging configuration settings, defining all aspects to manage logging in OCI. Please see the comments within each attribute for details."
  type = object({
    default_compartment_id   = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object.
    default_defined_tags     = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags    = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.
    log_group = optional(map(object({
      compartment_id   = optional(string)
      name             = string
      description      = optional(string)
      freeform_tags    = optional(map(string))
      defined_tags     = optional(map(string))
    })))
    service_logs = optional(map(object({    # the OCI service logs to manage in this configuration.
      compartment_id = optional(string)     # the compartment where the log is created. default_compartment_id is used if undefined.
      name               = string           # log name
      description        = optional(string) # log description. Defaults to log name if undefined.
      log_group_id       = string
      service            = string
      category           = string
      resource_id        = string
      is_enabled         = optional(bool, true)
      retention_duration = optional(number, 30)
      defined_tags       = optional(map(string)) # log defined_tags. default_defined_tags is used if undefined.
      freeform_tags      = optional(map(string)) # log freeform_tags. default_freeform_tags is used if undefined.
    })))
    custom_logs = optional(map(object({
      compartment_id     = optional(string)
      name               = string
      description        = optional(string) # log description. Defaults to log name if undefined.
      log_group_id       = string
      dynamic_groups     = list(string)
      channel            = optional(string)
      parser             = optional(string, "NONE")
      path               = list(string)
      is_enabled         = optional(bool, true)
      retention_duration = optional(number, 30)
      defined_tags       = optional(map(string)) # log defined_tags. default_defined_tags is used if undefined.
      freeform_tags      = optional(map(string))
    })))
  })
}

variable "enable_output" {
  description = "Whether Terraform should enable module output."
  type        = bool
  default     = true
}

variable "module_name" {
  description = "The module name."
  type        = string
  default     = "logging"
}
