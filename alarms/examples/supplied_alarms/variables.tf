# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "region" {description = "Your tenancy region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "alarms_configuration" {
  description = "Alarms configuration settings, defining all aspects to manage alarms in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_ocid = string,              # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    alarms = map(object({                           # the alarms to manage in this configuration.
      compartment_ocid         = optional(string)   # the compartment where the alarm is created. default_compartment_id is used if this is not defined.
      display_name             = string             # the alarm name.
      is_enabled               = optional(bool)     # if the alarm is enabled.
      preconfigured_alarm_type = optional(string)   # use a preconfigured alarm. can't use the query and namespace attributes if this is set.
      supplied_alarm           = optional(object({
        query                    = string       # specify the query for the alarm. can't use the preconfigured_alarm_type attribute if this is set.
        namespace                = string       # specify the namespace for the query. can't use the preconfigured_alarm_type attribute if this is set.
        severity                 = optional(string) # response required when the alarm is in the "FIRING" state. Valid values are: "CRITICAL", "ERROR", "WARNING", "INFO". Default is "WARNING".
        pending_duration         = optional(string) # the period of time the condition must persist before the alarm is fired. Default is 5 minutes: "PT5M"
        metric_compartment_ocid  = optional(string) # the compartment containing the metric being evaluated by the alarm.
        message_format           = optional(string) # format to use for notification messages sent from this alarm. Valid formats are: "RAW", "PRETTY_JSON", "ONS_OPTIMIZED". Default is "PRETTY_JSON".
      }))
      destination_topics = optional(object({ # the topics where alarms are sent to.
        existing_topic_ocids = optional(list(string)) # for using existing topics NOT managed in this configuration.
        topic_keys = optional(list(string)) # references to topics managed in this configuration.
      }))
      destination_streams = optional(object({ # the streams where alarms are sent to.
        existing_stream_ocids = optional(list(string)) # for using existing streams NOT managed in this configuration.
        stream_keys = optional(list(string)) # references to streams managed in this configuration.
      }))
      defined_tags             = optional(map(string))  # alarm defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags            = optional(map(string))  # alarm freeform_tags. default_freeform_tags is used if this is not defined.
    }))

    topics = optional(map(object({      # the topics to manage in this configuration.
      compartment_ocid = optional(string) # the compartment where the topic is created. default_compartment_id is used if this is not defined.
      name             = string           # the topic name
      description      = optional(string) # the topic description
      subscriptions    = optional(list(object({
        compartment_ocid = optional(string)      # the compartment where the subscription is created. topic compartment_id is used if this is not defined.
        protocol         = string                # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values           = list(string)          # list of endpoint values, specific to each protocol.
        defined_tags     = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.
        freeform_tags    = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.
      })))
      defined_tags  = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    streams = optional(map(object({ # the streams to manage in this configuration.
      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_id is used if this is not defined.
      name = string # the stream name
      num_partitions = optional(number) # the number of stream partitions. Default is 1.
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.
    })))
  })
}

