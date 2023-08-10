# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "region" {description = "Your tenancy region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "notifications_configuration" {
  description = "Notifications configuration settings, defining all aspects to manage notifications in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_id = string, # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    topics = optional(map(object({ # the topics to manage in this configuration.
      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined.
      name = string # topic name
      description = optional(string) # topic description. Defaults to topic name if undefined.
      subscriptions = optional(list(object({
        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values = list(string) # list of endpoint values, specific to each protocol.
        defined_tags = optional(map(string)) # subscription defined_tags. The topic defined_tags is used if undefined.
        freeform_tags = optional(map(string)) # subscription freeform_tags. The topic freeform_tags is used if undefined.
      })))
      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.
    })))
  })
}

