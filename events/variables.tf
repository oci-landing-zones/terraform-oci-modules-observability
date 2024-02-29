# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  description = "The tenancy OCID"
  type = string
  default = null
}

variable "events_configuration" {
  description = "Events configuration settings, defining all aspects to manage events in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_id = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    event_rules = map(object({

      compartment_id = optional(string)   # the compartment where rules are created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
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
      
      destination_topic_ids = optional(list(string)) # List of topics to send events to. This attribute is overloaded: values can be either topic OCIDs or references (keys) to the topics OCIDs. The references are first looked up in the topics attribute and then in the topics_dependency object. 
      destination_stream_ids = optional(list(string)) # List of streams to send events to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are first looked up in the streams attribute and then in the streams_dependency object. 
      destination_function_ids = optional(list(string)) # List of OCI functions to send events to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are looked up in the functions_dependency object. 
      
      defined_tags = optional(map(string)) # events defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # events freeform_tags. default_freeform_tags is used if this is not defined.
    }))
  
    topics = optional(map(object({ # the topics to manage in this configuration.
      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      name = string # the topic name
      description = optional(string) # the topic description
      subscriptions = optional(list(object({
        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS
        values = list(string) # list of endpoint values, specific to each protocol.
        defined_tags = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.
        freeform_tags = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.
      })))
      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    streams = optional(map(object({ # the streams to manage in this configuration.
      compartment_id = optional(string) # the compartment where the stream is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      name = string # the stream name
      num_partitions = optional(number) # the number of stream partitions. Default is 1.  
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.
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

variable functions_dependency {
  description = "A map of objects containing the externally managed OCI functions this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type." 
  type = map(any)
  default = null
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