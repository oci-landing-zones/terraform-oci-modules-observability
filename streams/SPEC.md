## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) |  < 1.3.0 |

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
| [oci_streaming_stream_pool.defaults](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream_pool) | resource |
| [oci_streaming_stream_pool.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable module output. | `bool` | `true` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"streams"` | no |
| <a name="input_streams_configuration"></a> [streams\_configuration](#input\_streams\_configuration) | Streams configuration settings, defining all aspects to manage streams in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_ocid = string, # the default compartment where all resources are defined. It's overriden by the compartment_ocid attribute within each object.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      name = string # the stream name<br>      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_ocid is used if this is not defined.<br>      stream_pool_key = optional(string) # the stream pool where the stream belongs. If defined, it should match of the keys provided in stream_pools object.<br>      num_partitions = optional(number) # the number of stream partitions. Default is "1"  <br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is "24" hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br><br>    stream_pools = optional(map(object({<br>      name = string # stream pool name<br>      compartment_ocid = optional(string) # the compartment where the stream pool is created. default_compartment_ocid is used if this is not defined.<br>      kms_key_ocid = optional(string) # the customer managed key used to encrypt streams in the stream pool<br>      private_endpoint_settings = optional(object({<br>        subnet_ocid = optional(string)<br>        private_endpoint_ip = optional(string)<br>        nsg_ocids = optional(list(string))<br>      }))<br>      kafka_settings = optional(object({ # settings for the Kafka compatibility layer.<br>        auto_create_topics_enabled = optional(bool)<br>        bootstrap_servers = optional(string)<br>        log_retention_in_hours = optional(number) # for how long messages are kept in the stream pool streams. Default is "24" hours.<br>        num_partitions = optional(number) # the number of stream partitions in the stream pool. Default is "1"<br>      }))<br>      defined_tags = optional(map(string)) # stream pool defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # stream pool freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br>    <br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_stream_pools"></a> [default\_stream\_pools](#output\_default\_stream\_pools) | The default stream pools. |
| <a name="output_stream_pools"></a> [stream\_pools](#output\_stream\_pools) | The (custom) stream pools. |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
