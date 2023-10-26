# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "The tenancy OCID"
  type = string
  default = null
}

variable "logging_configuration" {
  description = "Logging configuration settings, defining all aspects to manage logging in OCI. Please see the comments within each attribute for details."
  type = object({
    default_compartment_id   = string,                
    default_defined_tags     = optional(map(string)), 
    default_freeform_tags    = optional(map(string)), 
    log_groups = optional(map(object({
      compartment_id   = optional(string)
      name             = string
      description      = optional(string)
      freeform_tags    = optional(map(string))
      defined_tags     = optional(map(string))
    })))
    service_logs = optional(map(object({    
      name               = string           
      log_group_id       = string
      service            = string
      category           = string
      resource_id        = string
      is_enabled         = optional(bool)
      retention_duration = optional(number)
      defined_tags       = optional(map(string)) 
      freeform_tags      = optional(map(string)) 
    })))
    flow_logs = optional(map(object({
      name_prefix    = optional(string)
      log_group_id   = string
      target_resource_type = string 
      target_compartment_ids = list(string) 
      is_enabled         = optional(bool)
      retention_duration = optional(number)
      defined_tags       = optional(map(string)) 
      freeform_tags      = optional(map(string)) 
    })))
    bucket_logs = optional(map(object({
      name_prefix    = optional(string)
      log_group_id   = string
      target_compartment_ids = list(string) 
      category           = string 
      is_enabled         = optional(bool)
      retention_duration = optional(number)
      defined_tags       = optional(map(string)) 
      freeform_tags      = optional(map(string)) 
    })))
    custom_logs = optional(map(object({
      name               = string
      log_group_id       = string
      dynamic_groups     = list(string)
      parser_type        = optional(string)
      path               = list(string)
      is_enabled         = optional(bool)
      retention_duration = optional(number)
      defined_tags       = optional(map(string)) 
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

variable compartments_dependency {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type." 
  type = map(any)
  default = null
}