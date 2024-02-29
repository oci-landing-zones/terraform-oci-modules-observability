# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "The tenancy OCID"
  type = string
  default = null
}

variable "alarms_configuration" {
  description = "Alarms configuration settings, defining all aspects to manage alarms in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_id = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    alarms = map(object({                           # the alarms to manage in this configuration.
      compartment_id           = optional(string)   # the compartment where the alarm is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      display_name             = string             # the alarm name.
      is_enabled               = optional(bool)     # if the alarm is enabled. Default is true.
      preconfigured_alarm_type = optional(string)   # use a preconfigured alarm.
      supplied_alarm           = optional(object({
        query                    = string       # specify the query for the alarm. can't use the preconfigured_alarm_type attribute if this is set.
        namespace                = string       # specify the namespace for the query. can't use the preconfigured_alarm_type attribute if this is set.
        severity                 = optional(string) # response required when the alarm is in the "FIRING" state. Valid values are: "CRITICAL", "ERROR", "WARNING", "INFO". Default is "CRITICAL".
        pending_duration         = optional(string) # the period of time the condition must persist before the alarm is fired. Default is 5 minutes: "PT5M"
        metric_compartment_id    = optional(string)   # the compartment containing the metric being evaluated by the alarm. compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
        message_format           = optional(string) # format to use for notification messages sent from this alarm. Valid formats are: "RAW", "PRETTY_JSON", "ONS_OPTIMIZED". Default is "PRETTY_JSON".
        repeat_notification_critical_alarms = optional(string) #option to repeat critical alarms
      }))
      destination_topic_ids = optional(list(string)) # List of topics to send alarms to. This attribute is overloaded: values can be either topic OCIDs or references (keys) to the topics OCIDs. The references are first looked up in the topics attribute and then in the topics_dependency object. 
      destination_stream_ids = optional(list(string)) # List of streams to send alarms to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are first looked up in the streams attribute and then in the streams_dependency object. 
      defined_tags             = optional(map(string))  # alarm defined_tags. default_defined_tags is used if undefined.
      freeform_tags            = optional(map(string))  # alarm freeform_tags. default_freeform_tags is used if undefined.
    }))

    topics = optional(map(object({      # the topics to manage in this configuration.
      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      name             = string           # the topic name
      description      = optional(string) # the topic description
      subscriptions    = optional(list(object({
        compartment_id = optional(string)      # the compartment where the subscription is created. Topic compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
        protocol         = string                # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values           = list(string)          # list of endpoint values, specific to each protocol.
        defined_tags     = optional(map(string)) # subscription defined_tags. topic defined_tags is used if undefined.
        freeform_tags    = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if undefined.
      })))
      defined_tags  = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.
    })))

    streams = optional(map(object({ # the streams to manage in this configuration.
      compartment_id = optional(string) # the compartment where the stream is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      name = string # the stream name
      num_partitions = optional(number) # the number of stream partitions. Default is 1.  
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if undefined.
    })))
  })
}

variable compartments_dependency {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type." 
  type = map(any)
  default = null
}

variable topics_dependency {
  description = "A map of objects containing the externally managed topics this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type." 
  type = map(any)
  default = null
}

variable streams_dependency {
  description = "A map of objects containing the externally managed streams this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type." 
  type = map(any)
  default = null
}

variable "enable_output" {
  description = "Whether Terraform should enable the module output."
  type        = bool
  default     = true
}

variable module_name {
  description = "The module name."
  type = string
  default = "alarms"
}