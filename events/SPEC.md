## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | < 1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_events_rule.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/events_rule) | resource |
| [oci_ons_notification_topic.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_subscription) | resource |
| [oci_streaming_stream.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable the module output. | `bool` | `true` | no |
| <a name="input_events_configuration"></a> [events\_configuration](#input\_events\_configuration) | Events configuration settings, defining all aspects to manage events in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_ocid = string, # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    event_rules = map(object({<br><br>      compartment_ocid = optional(string) # the compartment where rules are created. default_compartment_id is used if this is not defined.<br>      is_enabled = optional(bool) # whether the rule should be enabled. Default is true.<br><br>      event_display_name = string # event display name.<br>      event_description = optional(string) # event description.<br><br>      preconfigured_events_categories = optional(list(string)) # valid values (case insensitive): iam, network, database, exainfra, storage, budget, compute, cloudguard<br>      <br>      supplied_events = optional(list(string)) # your own list of event conditions. It has precedence over preconfigured event conditions denoted by preconfigured_events_categories setting.<br>      <br>      attributes_filter = optional(list(object({ # a list of attribute filters to restrict which events are captured.<br>        attr = string # attribute name. Common attribute names: "compartmentId", "compartmentName", "resourceId", "availabilityDomain".<br>        value = list(string) # attribute value.<br>      }))) <br><br>      tags_filter = optional(list(object({ # a list of tag filters to restrict which events are captured. These are existing defined_tags.<br>        namespace = string # the tag namespace<br>        tags = list(object({ # a list of tags in the provided namespace.<br>          name = string # the tag name. Example: "CostCenter"<br>          value = string # the tag value. Example: "99"<br>        }))<br>      })))<br>      <br>      actions_topics = optional(object({ # the topics where events are sent to.<br>        existing_topic_ocids = optional(list(string)) # for using existing topics NOT managed in this configuration.<br>        topic_keys = optional(list(string)) # references to topics managed in this configuration.<br>      }))<br>      actions_streams = optional(object({ # the streams where events are sent to.<br>        existing_stream_ocids = optional(list(string)) # for using existing streams NOT managed in this configuration.<br>        stream_keys = optional(list(string)) # references to streams managed in this configuration.<br>      }))<br>      actions_functions = optional(object({ # the functions where events are sent to.<br>        existing_function_ocids = optional(list(string)) # for using existing functions NOT managed in this configuration.<br>      }))<br>      defined_tags = optional(map(string)) # events defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # events freeform_tags. default_freeform_tags is used if this is not defined.<br>    }))<br>  <br>    topics = optional(map(object({ # the topics to manage in this configuration.<br>      compartment_ocid = optional(string) # the compartment where the topic is created. default_compartment_id is used if this is not defined.<br>      name = string # the topic name<br>      description = optional(string) # the topic description<br>      subscriptions = optional(list(object({<br>        compartment_ocid = optional(string) # the compartment where the subscription is created. topic compartment_id is used if this is not defined.<br>        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS<br>        values = list(string) # list of endpoint values, specific to each protocol.<br>        defined_tags = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.<br>        freeform_tags = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.<br>      })))<br>      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_id is used if this is not defined.<br>      name = string # the stream name<br>      num_partitions = optional(number) # the number of stream partitions. Default is 1.  <br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"events"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_events"></a> [events](#output\_events) | The events. |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions. |
| <a name="output_topics"></a> [topics](#output\_topics) | The topics. |
