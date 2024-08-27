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
| [oci_events_rule.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/events_rule) | resource |
| [oci_ons_notification_topic.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_subscription) | resource |
| [oci_streaming_stream.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable the module output. | `bool` | `true` | no |
| <a name="input_events_configuration"></a> [events\_configuration](#input\_events\_configuration) | Events configuration settings, defining all aspects to manage events in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_id = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    event_rules = map(object({<br><br>      compartment_id = optional(string)   # the compartment where rules are created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      is_enabled = optional(bool) # whether the rule should be enabled. Default is true.<br><br>      event_display_name = string # event display name.<br>      event_description = optional(string) # event description.<br><br>      preconfigured_events_categories = optional(list(string)) # valid values (case insensitive): iam, network, database, exainfra, storage, budget, compute, cloudguard<br>      <br>      supplied_events = optional(list(string)) # your own list of event conditions. It has precedence over preconfigured event conditions denoted by preconfigured_events_categories setting.<br>      <br>      attributes_filter = optional(list(object({ # a list of attribute filters to restrict which events are captured.<br>        attr = string # attribute name. Common attribute names: "compartmentId", "compartmentName", "resourceId", "availabilityDomain".<br>        value = list(string) # attribute value.<br>      }))) <br><br>      tags_filter = optional(list(object({ # a list of tag filters to restrict which events are captured. These are existing defined_tags.<br>        namespace = string # the tag namespace<br>        tags = list(object({ # a list of tags in the provided namespace.<br>          name = string # the tag name. Example: "CostCenter"<br>          value = string # the tag value. Example: "99"<br>        }))<br>      })))<br>      <br>      destination_topic_ids = optional(list(string)) # List of topics to send events to. This attribute is overloaded: values can be either topic OCIDs or references (keys) to the topics OCIDs. The references are first looked up in the topics attribute and then in the topics_dependency object. <br>      destination_stream_ids = optional(list(string)) # List of streams to send events to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are first looked up in the streams attribute and then in the streams_dependency object. <br>      destination_function_ids = optional(list(string)) # List of OCI functions to send events to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are looked up in the functions_dependency object. <br>      <br>      defined_tags = optional(map(string)) # events defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # events freeform_tags. default_freeform_tags is used if this is not defined.<br>    }))<br>  <br>    topics = optional(map(object({ # the topics to manage in this configuration.<br>      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      name = string # the topic name<br>      description = optional(string) # the topic description<br>      subscriptions = optional(list(object({<br>        protocol = string # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS<br>        values = list(string) # list of endpoint values, specific to each protocol.<br>        defined_tags = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.<br>        freeform_tags = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.<br>      })))<br>      defined_tags = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      compartment_id = optional(string) # the compartment where the stream is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      name = string # the stream name<br>      num_partitions = optional(number) # the number of stream partitions. Default is 1.  <br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_functions_dependency"></a> [functions\_dependency](#input\_functions\_dependency) | A map of objects containing the externally managed OCI functions this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"events"` | no |
| <a name="input_streams_dependency"></a> [streams\_dependency](#input\_streams\_dependency) | A map of objects containing the externally managed streams this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The tenancy OCID | `string` | `null` | no |
| <a name="input_topics_dependency"></a> [topics\_dependency](#input\_topics\_dependency) | A map of objects containing the externally managed topics this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_events"></a> [events](#output\_events) | The events. |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions. |
| <a name="output_topics"></a> [topics](#output\_topics) | The topics. |
