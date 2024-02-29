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
| [oci_monitoring_alarm.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |
| [oci_ons_notification_topic.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_subscription) | resource |
| [oci_streaming_stream.these](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarms_configuration"></a> [alarms\_configuration](#input\_alarms\_configuration) | Alarms configuration settings, defining all aspects to manage alarms in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_id = string,                # the default compartment where all resources are defined. It's overriden by the compartment_id attribute within each object. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    alarms = map(object({                           # the alarms to manage in this configuration.<br>      compartment_id           = optional(string)   # the compartment where the alarm is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      display_name             = string             # the alarm name.<br>      is_enabled               = optional(bool)     # if the alarm is enabled. Default is true.<br>      preconfigured_alarm_type = optional(string)   # use a preconfigured alarm.<br>      supplied_alarm           = optional(object({<br>        query                    = string       # specify the query for the alarm. can't use the preconfigured_alarm_type attribute if this is set.<br>        namespace                = string       # specify the namespace for the query. can't use the preconfigured_alarm_type attribute if this is set.<br>        severity                 = optional(string) # response required when the alarm is in the "FIRING" state. Valid values are: "CRITICAL", "ERROR", "WARNING", "INFO". Default is "CRITICAL".<br>        pending_duration         = optional(string) # the period of time the condition must persist before the alarm is fired. Default is 5 minutes: "PT5M"<br>        metric_compartment_id    = optional(string)   # the compartment containing the metric being evaluated by the alarm. compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>        message_format           = optional(string) # format to use for notification messages sent from this alarm. Valid formats are: "RAW", "PRETTY_JSON", "ONS_OPTIMIZED". Default is "PRETTY_JSON".<br>        repeat_frequency_for_critical_alarms = optional(string) #option to repeat critical alarms<br>      }))<br>      destination_topic_ids = optional(list(string)) # List of topics to send alarms to. This attribute is overloaded: values can be either topic OCIDs or references (keys) to the topics OCIDs. The references are first looked up in the topics attribute and then in the topics_dependency object. <br>      destination_stream_ids = optional(list(string)) # List of streams to send alarms to. This attribute is overloaded: values can be either stream OCIDs or references (keys) to the streams OCIDs. The references are first looked up in the streams attribute and then in the streams_dependency object. <br>      defined_tags             = optional(map(string))  # alarm defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags            = optional(map(string))  # alarm freeform_tags. default_freeform_tags is used if undefined.<br>    }))<br><br>    topics = optional(map(object({      # the topics to manage in this configuration.<br>      compartment_id = optional(string) # the compartment where the topic is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      name             = string           # the topic name<br>      description      = optional(string) # the topic description<br>      subscriptions    = optional(list(object({<br>        compartment_id = optional(string)      # the compartment where the subscription is created. Topic compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>        protocol         = string                # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS<br>        values           = list(string)          # list of endpoint values, specific to each protocol.<br>        defined_tags     = optional(map(string)) # subscription defined_tags. topic defined_tags is used if undefined.<br>        freeform_tags    = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if undefined.<br>      })))<br>      defined_tags  = optional(map(string)) # topic defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if undefined.<br>    })))<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      compartment_id = optional(string) # the compartment where the stream is created. default_compartment_id is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.<br>      name = string # the stream name<br>      num_partitions = optional(number) # the number of stream partitions. Default is 1.  <br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if undefined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if undefined.<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_compartments_dependency"></a> [compartments\_dependency](#input\_compartments\_dependency) | A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the compartment OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable the module output. | `bool` | `true` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"alarms"` | no |
| <a name="input_streams_dependency"></a> [streams\_dependency](#input\_streams\_dependency) | A map of objects containing the externally managed streams this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type. | `map(any)` | `null` | no |
| <a name="input_tenancy_ocid"></a> [tenancy\_ocid](#input\_tenancy\_ocid) | The tenancy OCID | `string` | `null` | no |
| <a name="input_topics_dependency"></a> [topics\_dependency](#input\_topics\_dependency) | A map of objects containing the externally managed topics this module may depend on. All map objects must have the same type and must contain at least an 'id' attribute (representing the topic OCID) of string type. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarms"></a> [alarms](#output\_alarms) | The alarms |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions. |
| <a name="output_topics"></a> [topics](#output\_topics) | The topics. |
