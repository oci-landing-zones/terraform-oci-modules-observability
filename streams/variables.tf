# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "streams_configuration" {
  description = "Streams configuration settings, defining all aspects to manage streams in OCI. Please see the comments within each attribute for details."
  type = object({

    default_compartment_id = optional(string), # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.
    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.

    streams = optional(map(object({ # the streams to manage in this configuration.
      name = string # the stream name
      compartment_id = optional(string) # the compartment where the stream is created. Use it when the Stream belongs to Default Stream Pool. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      stream_pool_id = optional(string) # the stream pool where the stream belongs. It has precedence over compartment_id. Wen used, the Stream is created in the same compartment as the Stream Pool. Use it when the Stream belongs to a custom Stream Pool (defined in stream_pools). If set, this value must be set to a key in the stream_pools object. 
      num_partitions = optional(number) # the number of stream partitions. Default is "1".
      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is "24" hours.
      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if undefined.
    })))

    stream_pools = optional(map(object({
      name = string # stream pool name
      compartment_id = optional(string) # the compartment where the stream pool is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
      kms_key_id = optional(string) # the customer managed key used to encrypt streams in the Stream Pool. This attribute is overloaded: it can be either an encryption Key OCID or a reference (a key) to the encryption Key OCID.
      private_endpoint_settings = optional(object({
        subnet_id = string # the subnet the Stream Pool is assigned.
        private_endpoint_ip = optional(string) # the IP address for the Stream Pool. A random IP address from the subnet is assigned if undefined.
        nsg_ids = optional(list(string)) # the network security groups the Stream Pool IP address is added to.
      }))
      kafka_settings = optional(object({ # settings for the Kafka compatibility layer.
        auto_create_topics_enabled = optional(bool)
        bootstrap_servers = optional(string)
        log_retention_in_hours = optional(number) # for how long messages are kept in the stream pool streams. Default is "24" hours.
        num_partitions = optional(number) # the number of stream partitions in the stream pool. Default is "1"
      }))
      defined_tags = optional(map(string)) # stream pool defined_tags. default_defined_tags is used if undefined.
      freeform_tags = optional(map(string)) # stream pool freeform_tags. default_freeform_tags is used if undefined.
    })))
    
  })
}

variable compartments_dependency {
  description = "A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the compartment OCID." 
  type = map(any)
  default = null
}

variable kms_dependency {
  description = "A map of objects containing the externally managed encryption keys this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the encryption Key OCID." 
  type = map(any)
  default = null
}

variable network_dependency {
  description = "A map of objects containing the externally managed subnets and NSGs this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the subnet and NSG OCID." 
  type = map(any)
  default = null
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
