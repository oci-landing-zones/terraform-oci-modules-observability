# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "events_configuration" {
  description = "Events configuration settings, defining all aspects to manage events in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_ocid = string, # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    event_rules = map(object({

      compartment_ocid = optional(string) # the compartment where rules are created. default_compartment_id is used if this is not defined.
      is_enabled = optional(bool) # whether the rule should be enabled. Default is true.

      event_display_name = string # event display name.
      event_description = optional(string) # event description.

      preconfigured_events_categories = optional(list(string)) # valid values (case insensitive): iam, network, database, exainfra, storage, budget, compute, cloudguard
      
      supplied_events = optional(list(string)) # your own list of event conditions. It has precedence over preconfigured event conditions denoted by preconfigured_events_categories setting.
      
      attributes_filter = optional(list(object({ # a list of attribute filters to restrict which events are captured.
        attr = string # attribute name. Common attribute names: "compartmentId", "compartmentName", "resourceId", "availabilityDomain".
        value = list(string) # attribute value.
      }))) 

      tags_filter = optional(list(object({ # a list of tag filters to restrict which events are captured. These are existing defined_tags.
        namespace = string # the tag namespace
        tags = list(object({ # a list of tags in the provided namespace.
          name = string # the tag name. Example: "CostCenter"
          value = string # the tag value. Example: "99"
        }))
      })))
      
      actions_topics = optional(object({ # the topics where events are sent to.
        existing_topic_ocids = optional(list(string)) # for using existing topics NOT managed in this configuration.
        topic_keys = optional(list(string)) # references to topics managed in this configuration.
      }))
      actions_streams = optional(object({ # the streams where events are sent to.
        existing_stream_ocids = optional(list(string)) # for using existing streams NOT managed in this configuration.
        stream_keys = optional(list(string)) # references to streams managed in this configuration.
      }))
      actions_functions = optional(object({ # the functions where events are sent to.
        existing_function_ocids = optional(list(string)) # for using existing functions NOT managed in this configuration.
      }))
      defined_tags = optional(map(string)) # events defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # events freeform_tags. default_freeform_tags is used if this is not defined.
    }))
  
    topics = optional(map(object({ # the topics to manage in this configuration.
      compartment_ocid = optional(string) # the compartment where the topic is created. default_compartment_id is used if this is not defined.
      name = string # the topic name
      description = optional(string) # the topic description
      subscriptions = optional(list(object({
        compartment_ocid = optional(string) # the compartment where the subscription is created. topic compartment_id is used if this is not defined.
        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values = list(string) # list of endpoint values, specific to each protocol.
        defined_tags = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.
        freeform_tags = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.
      })))
      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.
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

variable enable_output {
  description = "Whether Terraform should enable the module output."
  type = bool
  default = true
}

variable module_name {
  description = "The module name."
  type = string
  default = "events"
}