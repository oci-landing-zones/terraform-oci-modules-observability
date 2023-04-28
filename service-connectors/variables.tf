# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    description = "The tenancy ocid"
    type = string
}
variable "service_connectors_configuration" {
  description = "Service Connectors configuration settings, defining all aspects to manage service connectors and related resources in OCI. Please see the comments within each attribute for details."

  type = object({
    default_compartment_ocid = string, # the default compartment where all resources are defined. It's overriden by the compartment_ocid attribute within each object.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    service_connectors = map(object({
      display_name = string # the service connector name.
      compartment_ocid = optional(string) # the compartment ocid where the service connector is created.
      description = optional(string) # the service connector description. Defaults to display_name if not defined.
      activate = optional(bool) # whether the service connector is active. Default is false.
      defined_tags = optional(map(string)) # the service connector defined_tags. Default to default_defined_tags if undefined.
      freeform_tags = optional(map(string)) # the service connector freeform_tags. Default to default_freeform_tags if undefined.

      source = object({
        kind = string # Supported sources: "logging" and "streaming".
        audit_logs = optional(list(object({ # the audit logs
          cmp_ocid = string # the compartment ocid. Use "ALL" to include all audit logs in the tenancy.
        })))
        non_audit_logs = optional(list(object({ # all logs that are not audit logs. Includes bucket logs, flow logs, custom logs, etc.
          cmp_ocid = string # the compartment ocid.
          log_group_ocid = optional(string) # the log group ocid.
          log_ocid = optional(string) # the log ocid.
        })))
        stream_ocid = optional(string) # The existing stream ocid (only applicable if kind = "streaming").
      })

      log_rule_filter = optional(string) # A condition for filtering log data (only applicable if source kind = "logging").
      
      target = object({ # the target
        kind = string, # supported targets: "objectstorage", "streaming", "functions", "logginganalytics", "notifications".
        bucket_name = optional(string), # the existing bucket name (only applicable if kind is "objectstorage").
        bucket_key = optional(string), # the corresponding bucket key as defined in the buckets map object (only applicable if kind is "objectstorage"). 
        bucket_batch_rollover_size_in_mbs = optional(number), # the bucket batch rollover size in megabytes (only applicable if kind is "objectstorage"). 
        bucket_batch_rollover_time_in_ms = optional(number), # the bucket batch rollover time in milliseconds (only applicable if kind is "objectstorage"). 
        bucket_object_name_prefix = optional(string), # the prefix of objects eventually created in the bucket (only applicable if kind is "objectstorage").
        stream_ocid = optional(string) # the existing stream ocid (only applicable if kind is "streaming").
        stream_key = optional(string) # the corresponding stream key as defined in the streams map object (only applicable if kind is "streaming"). 
        topic_ocid = optional(string) # the existing topic ocid (only applicable if kind is "notifications").
        topic_key = optional(string) # the corresponding topic key as defined in the topics map object (only applicable if kind is "notifications").
        function_ocid = optional(string) # the existing function ocid (only applicable if kind is "functions").
        log_group_ocid = optional(string) # the existing log group ocid (only applicable if kind is "logginganalytics").
        compartment_ocid = optional(string), # the target resource compartment ocid. Required when using an existing target resource (bucket_name, stream_ocid, function_ocid, or log_group_ocid).
        policy_name = optional(string) # the policy name allowing service connector to push data to target.
        policy_description = optional(string) # the policy description.
      })
    }))  

    buckets = optional(map(object({ # the buckets to manage.
      name = string, # the bucket name
      compartment_ocid = optional(string), # the compartment where the stream is created. default_compartment_ocid is used if this is not defined.
      cis_level = optional(string), # the cis_level. Default is "1". Drives bucket versioning and encryption. cis_level = "1": no versioning, encryption with Oracle managed key. cis_level = "2": versioning enabled, encryption with customer managed key.
      kms_key_ocid = optional(string), # the customer managed key ocid. Required if cis_level = "2".
      defined_tags = optional(map(string)), # bucket defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # bucket freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    streams = optional(map(object({ # the streams to manage.
      name = string # the stream name
      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_ocid is used if this is not defined.
      num_partitions = optional(number) # the number of stream partitions. Default is 1.  
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    topics = optional(map(object({ # the topics to manage in this configuration.
      name = string # topic name
      compartment_ocid = optional(string) # the compartment where the topic is created. default_compartment_ocid is used if undefined.
      description = optional(string) # topic description. Defaults to topic name if undefined.
      subscriptions = optional(list(object({
        compartment_ocid = optional(string) # the compartment where the subscription is created. The topic compartment_ocid is used if undefined.
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

variable enable_output {
  description = "Whether Terraform should enable module output."
  type = bool
  default = true
}

variable module_name {
  description = "The module name."
  type = string
  default = "service-connectors"
}
