# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "notifications_configuration" {
  description = "Notifications configuration settings, defining all aspects to manage notifications in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_id = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. It can be either a compartment OCID or a reference (a key) to the compartment OCID.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    topics = optional(map(object({      # the topics to manage in this configuration.
      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. It can be either a compartment OCID or a reference (a key) to the compartment OCID.
      name           = string           # topic name
      description    = optional(string) # topic description. Defaults to topic name if undefined.
      subscriptions = optional(list(object({
        protocol      = string                # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values        = list(string)          # list of endpoint values, specific to each protocol.
        defined_tags  = optional(map(string)) # subscription defined_tags. The topic defined_tags is used if undefined.
        freeform_tags = optional(map(string)) # subscription freeform_tags. The topic freeform_tags is used if undefined.
      })))
      defined_tags  = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.
    })))
    announcement_subscriptions = optional(map(object({
      compartment_id        = optional(string)
      display_name          = string
      notification_topic_id = string
      description           = optional(string)
      defined_tags          = optional(map(string))
      freeform_tags         = optional(map(string))
      preferred_language    = optional(string)
      preferred_time_zone   = optional(string)
      filter_groups = optional(map(object({
        name         = string
        filter_type  = string
        filter_value = list(string)
      })))
    })))
  })
}

variable "compartments_dependency" {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type."
  type        = map(any)
  default     = null
}

variable "enable_output" {
  description = "Whether Terraform should enable module output."
  type        = bool
  default     = true
}

variable "module_name" {
  description = "The module name."
  type        = string
  default     = "notifications"
}
