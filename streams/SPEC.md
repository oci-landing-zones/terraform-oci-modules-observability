## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_streaming_stream.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) | resource |
| [oci_streaming_stream_pool.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the compartment OCID. | `map(any)` | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable module output. | `bool` | `true` | no |
| <a name="input_kms_dependency"></a> [kms\_dependency](#input\_kms\_dependency) | A map of objects containing the externally managed encryption keys this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the encryption Key OCID. | `map(any)` | `null` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"streams"` | no |
| <a name="input_network_dependency"></a> [network\_dependency](#input\_network\_dependency) | A map of objects containing the externally managed subnets and NSGs this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute with the subnet and NSG OCID. | `map(any)` | `null` | no |
| <a name="input_streams_configuration"></a> [streams\_configuration](#input\_streams\_configuration) | Streams configuration settings, defining all aspects to manage streams in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_id = optional(string), # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      name = string # the stream name<br>      compartment_id = optional(string) # the compartment where the stream is created. Use it when the Stream belongs to Default Stream Pool. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      stream_pool_id = optional(string) # the stream pool where the stream belongs. It has precedence over compartment_id. Wen used, the Stream is created in the same compartment as the Stream Pool. Use it when the Stream belongs to a custom Stream Pool (defined in stream_pools). If set, this value must be set to a key in the stream_pools object. <br>      num_partitions = optional(number) # the number of stream partitions. Default is "1".<br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is "24" hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if undefined.<br>    })))<br><br>    stream_pools = optional(map(object({<br>      name = string # stream pool name<br>      compartment_id = optional(string) # the compartment where the stream pool is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      kms_key_id = optional(string) # the customer managed key used to encrypt streams in the Stream Pool. This attribute is overloaded: it can be either an encryption Key OCID or a reference (a key) to the encryption Key OCID.<br>      private_endpoint_settings = optional(object({<br>        subnet_id = string # the subnet the Stream Pool is assigned.<br>        private_endpoint_ip = optional(string) # the IP address for the Stream Pool. A random IP address from the subnet is assigned if undefined.<br>        nsg_ids = optional(list(string)) # the network security groups the Stream Pool IP address is added to.<br>      }))<br>      kafka_settings = optional(object({ # settings for the Kafka compatibility layer.<br>        auto_create_topics_enabled = optional(bool)<br>        bootstrap_servers = optional(string)<br>        log_retention_in_hours = optional(number) # for how long messages are kept in the stream pool streams. Default is "24" hours.<br>        num_partitions = optional(number) # the number of stream partitions in the stream pool. Default is "1"<br>      }))<br>      defined_tags = optional(map(string)) # stream pool defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags = optional(map(string)) # stream pool freeform_tags. default_freeform_tags is used if undefined.<br>    })))<br>    <br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_pools"></a> [stream\_pools](#output\_stream\_pools) | The (custom) stream pools. |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
