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
| <a name="input_alarms_configuration"></a> [alarms\_configuration](#input\_alarms\_configuration) | Alarms configuration settings, defining all aspects to manage alarms in OCI. Please see the comments within each attribute for details. | <pre>object({<br><br>    default_compartment_ocid = string,              # the default compartment where all resources are defined. It's overriden by the compartment_ocid attribute within each object.<br>    default_defined_tags   = optional(map(string)), # the default defined tags. It's overriden by the defined_tags attribute within each object.<br>    default_freeform_tags  = optional(map(string)), # the default freeform tags. It's overriden by the frreform_tags attribute within each object.<br><br>    alarms = map(object({                           # the alarms to manage in this configuration.<br>      compartment_ocid         = optional(string)   # the compartment where the alarm is created. default_compartment_ocid is used if this is not defined.<br>      display_name             = string             # the alarm name.<br>      is_enabled               = optional(bool)     # if the alarm is enabled. Default is true.<br>      preconfigured_alarm_type = optional(string)   # use a preconfigured alarm.<br>      supplied_alarm           = optional(object({<br>        query                    = string       # specify the query for the alarm. can't use the preconfigured_alarm_type attribute if this is set.<br>        namespace                = string       # specify the namespace for the query. can't use the preconfigured_alarm_type attribute if this is set.<br>        severity                 = optional(string) # response required when the alarm is in the "FIRING" state. Valid values are: "CRITICAL", "ERROR", "WARNING", "INFO". Default is "CRITICAL".<br>        pending_duration         = optional(string) # the period of time the condition must persist before the alarm is fired. Default is 5 minutes: "PT5M"<br>        metric_compartment_ocid  = optional(string) # the compartment containing the metric being evaluated by the alarm. compartment_ocid is used if not defined.<br>        message_format           = optional(string) # format to use for notification messages sent from this alarm. Valid formats are: "RAW", "PRETTY_JSON", "ONS_OPTIMIZED". Default is "PRETTY_JSON".<br>      }))<br>      destination_topics = optional(object({ # the topics where alarms are sent to.<br>        existing_topic_ocids = optional(list(string)) # for using existing topics NOT managed in this configuration.<br>        topic_keys = optional(list(string)) # references to topics managed in this configuration.<br>      }))<br>      destination_streams = optional(object({ # the streams where alarms are sent to.<br>        existing_stream_ocids = optional(list(string)) # for using existing streams NOT managed in this configuration.<br>        stream_keys = optional(list(string)) # references to streams managed in this configuration.<br>      }))<br>      defined_tags             = optional(map(string))  # alarm defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags            = optional(map(string))  # alarm freeform_tags. default_freeform_tags is used if this is not defined.<br>    }))<br><br>    topics = optional(map(object({      # the topics to manage in this configuration.<br>      compartment_ocid = optional(string) # the compartment where the topic is created. default_compartment_ocid is used if this is not defined.<br>      name             = string           # the topic name<br>      description      = optional(string) # the topic description<br>      subscriptions    = optional(list(object({<br>        compartment_ocid = optional(string)      # the compartment where the subscription is created. topic compartment_id is used if this is not defined.<br>        protocol         = string                # valid values (case insensitive): EMAIL, CUSTOM_HTTPS, PAGERDUTY, SLACK, ORACLE_FUNCTIONS, SMS<br>        values           = list(string)          # list of endpoint values, specific to each protocol.<br>        defined_tags     = optional(map(string)) # subscription defined_tags. topic defined_tags is used if this is not defined.<br>        freeform_tags    = optional(map(string)) # subscription freeform_tags. topic freeform_tags is used if this is not defined.<br>      })))<br>      defined_tags  = optional(map(string)) # topic defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # topic freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br><br>    streams = optional(map(object({ # the streams to manage in this configuration.<br>      compartment_ocid = optional(string) # the compartment where the stream is created. default_compartment_ocid is used if this is not defined.<br>      name = string # the stream name<br>      num_partitions = optional(number) # the number of stream partitions. Default is 1.  <br>      log_retention_in_hours = optional(number) # for how long to keep messages in the stream. Default is 24 hours.<br>      defined_tags = optional(map(string)) # stream defined_tags. default_defined_tags is used if this is not defined.<br>      freeform_tags = optional(map(string)) # stream freeform_tags. default_freeform_tags is used if this is not defined.<br>    })))<br>  })</pre> | n/a | yes |
| <a name="input_enable_output"></a> [enable\_output](#input\_enable\_output) | Whether Terraform should enable the module output. | `bool` | `true` | no |
| <a name="input_module_name"></a> [module\_name](#input\_module\_name) | The module name. | `string` | `"alarms"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarms"></a> [alarms](#output\_alarms) | The alarms |
| <a name="output_streams"></a> [streams](#output\_streams) | The streams. |
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The subscriptions. |
| <a name="output_topics"></a> [topics](#output\_topics) | The topics. |
