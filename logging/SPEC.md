## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) |  < 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_log_analytics_log_analytics_log_group.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/log_analytics_log_analytics_log_group) | resource |
| [oci_log_analytics_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/log_analytics_namespace) | resource |
| [oci_logging_log.bucket_logs](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log.flow_logs](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log.these_custom](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log_group.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group) | resource |
| [oci_logging_unified_agent_configuration.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_unified_agent_configuration) | resource |
| [time_sleep.log_group_propagation_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_core_private_ips.nlbs](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_private_ips) | data source |
| [oci_core_subnets.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_subnets) | data source |
| [oci_core_vcns.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_vcns) | data source |
| [oci_core_vnic.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_vnic) | data source |
| [oci_core_vnic_attachments.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_vnic_attachments) | data source |
| [oci_identity_compartment.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) | data source |
| [oci_log_analytics_namespaces.logging_analytics_namespaces](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/log_analytics_namespaces) | data source |
| [oci_network_load_balancer_network_load_balancers.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/network_load_balancer_network_load_balancers) | data source |
| [oci_objectstorage_bucket_summaries.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_bucket_summaries)                             | data source |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace)                                            | data source |
| [oci_log_analytics_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/log_analytics_namespace)                                            | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable module output. | `bool` | `true` | no |
| <a name="input_logging_configuration"></a> [logging\_configuration](#input\_logging\_configuration) | Logging configuration settings, defining all aspects to manage logging in OCI. Please see the comments within each attribute for details. | <pre>object({<br>    default_compartment_id    = string,<br>    default_defined_tags      = optional(map(string)),<br>    default_freeform_tags     = optional(map(string)),<br>    onboard_logging_analytics = optional(bool),<br>    log_groups = map(object({<br>      type           = optional(string)<br>      compartment_id = optional(string)<br>      name           = string<br>      description    = optional(string)<br>      freeform_tags  = optional(map(string))<br>      defined_tags   = optional(map(string))<br>    }))<br>    service_logs = optional(map(object({<br>      name               = string<br>      log_group_id       = string<br>      service            = string<br>      category           = string<br>      resource_id        = string<br>      is_enabled         = optional(bool)<br>      retention_duration = optional(number)<br>      defined_tags       = optional(map(string))<br>      freeform_tags      = optional(map(string))<br>    })))<br>    flow_logs = optional(map(object({<br>      name_prefix            = optional(string)<br>      log_group_id           = string<br>      target_resource_type   = string<br>      target_compartment_ids = list(string)<br>      is_enabled             = optional(bool)<br>      retention_duration     = optional(number)<br>      defined_tags           = optional(map(string))<br>      freeform_tags          = optional(map(string))<br>    })))<br>    bucket_logs = optional(map(object({<br>      name_prefix            = optional(string)<br>      log_group_id           = string<br>      target_compartment_ids = list(string)<br>      category               = string<br>      is_enabled             = optional(bool)<br>      retention_duration     = optional(number)<br>      defined_tags           = optional(map(string))<br>      freeform_tags          = optional(map(string))<br>    })))<br>    custom_logs = optional(map(object({<br>      name               = string<br>      log_group_id       = string<br>      dynamic_groups     = list(string)<br>      parser_type        = optional(string)<br>      path               = list(string)<br>      is_enabled         = optional(bool)<br>      retention_duration = optional(number)<br>      defined_tags       = optional(map(string))<br>      freeform_tags      = optional(map(string))<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"logging"` | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The tenancy OCID | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_logs"></a> [custom\_logs](#output\_custom\_logs) | The custom logs. |
| <a name="output_custom_logs_agent_config"></a> [custom\_logs\_agent\_config](#output\_custom\_logs\_agent\_config) | The agent configurations for custom logs. |
| <a name="output_log_groups"></a> [log\_groups](#output\_log\_groups) | The log groups. |
| <a name="output_logging_analytics_log_groups"></a> [logging\_analytics\_log\_groups](#output\_logging\_analytics\_log\_groups) | Logging analytics log groups |
| <a name="output_service_logs"></a> [service\_logs](#output\_service\_logs) | The logs. |

