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
| [oci_ons_notification_topic.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable module output. | `bool` | `true` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"notifications"` | no |
| <a name="input_notifications_configuration"></a> [notifications\_configuration](#input\_notifications\_configuration) | Notifications configuration settings, defining all aspects to manage notifications in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_id = string, # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. It can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    topics = optional(map(object({ # the topics to manage in this configuration.<br>      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. It can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      name = string # topic name<br>      description = optional(string) # topic description. Defaults to topic name if undefined.<br>      subscriptions = optional(list(object({<br>        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS<br>        values = list(string) # list of endpoint values, specific to each protocol.<br>        defined_tags = optional(map(string)) # subscription defined_tags. The topic defined_tags is used if undefined.<br>        freeform_tags = optional(map(string)) # subscription freeform_tags. The topic freeform_tags is used if undefined.<br>      })))<br>      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.<br>    })))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions. |
| <a name="output_topics"></a> [topics](#output\_topics) | The topics. |
