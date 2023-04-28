# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "streams_configuration" {
  description = "Streams configuration settings, defining all aspects to manage streams in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_ocid = string, # the default compartment where all resources are defined. It's overriden by the compartment_ocid attribute within each object.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    streams = optional(map(object({ # the streams to manage in this configuration.
      name = string # the stream name
      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_ocid is used if this is not defined.
      stream_pool_key = optional(string) # the stream pool where the stream belongs. If defined, it should match of the keys provided in stream_pools object.
      num_partitions = optional(number) # the number of stream partitions. Default is "1"  
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is "24" hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.
    })))

    stream_pools = optional(map(object({
      name = string # stream pool name
      compartment_ocid = optional(string) # the compartment where the stream pool is created. default_compartment_ocid is used if this is not defined.
      kms_key_ocid = optional(string) # the customer managed key used to encrypt streams in the stream pool
      private_endpoint_settings = optional(object({
        subnet_ocid = optional(string)
        private_endpoint_ip = optional(string)
        nsg_ocids = optional(list(string))
      }))
      kafka_settings = optional(object({ # settings for the Kafka compatibility layer.
        auto_create_topics_enabled = optional(bool)
        bootstrap_servers = optional(string)
        log_retention_in_hours = optional(number) # for how long messages are kept in the stream pool streams. Default is "24" hours.
        num_partitions = optional(number) # the number of stream partitions in the stream pool. Default is "1"
      }))
      defined_tags = optional(map(string)) # stream pool defined_tags. default_defined_tags is used if this is not defined.
      freeform_tags = optional(map(string)) # stream pool freeform_tags. default_freeform_tags is used if this is not defined.
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
  default = "streams"
}
