# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  subscriptions = flatten([
    for topic_key, topic in(var.alarms_configuration["topics"] != null ? var.alarms_configuration["topics"] : {}) : [
      for subs in(topic["subscriptions"] != null ? topic["subscriptions"] : []) : [
        for value in subs["values"] : {
          key            = "${topic_key}.${value}"
          compartment_id = topic.compartment_id != null ? (length(regexall("^ocid1.*$", topic.compartment_id)) > 0 ? topic.compartment_id : var.compartments_dependency[topic.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id)
          protocol       = upper(subs.protocol)
          endpoint       = value
          topic_id       = oci_ons_notification_topic.these[topic_key].id
          defined_tags   = subs.defined_tags != null ? subs.defined_tags : topic.defined_tags != null ? topic.defined_tags : var.alarms_configuration.default_defined_tags
          freeform_tags  = merge(local.cislz_module_tag, subs.freeform_tags != null ? subs.freeform_tags : topic.freeform_tags != null ? topic.freeform_tags : var.alarms_configuration.default_freeform_tags)
        }
      ]
    ]
  ])

  subscription_protocols = ["EMAIL", "CUSTOM_HTTPS", "SLACK", "PAGERDUTY", "ORACLE_FUNCTIONS", "SMS"]

}

resource "oci_monitoring_alarm" "these" {
  #Required
  for_each = var.alarms_configuration["alarms"]
  lifecycle {
    precondition {
      condition     = each.value.preconfigured_alarm_type != null ? contains(keys(local.preconfigured_alarms), each.value.preconfigured_alarm_type) : true
      error_message = "VALIDATION FAILURE"
    }
  }
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id)
  destinations   = each.value.destination_topic_ids != null || each.value.destination_stream_ids != null ? setunion(
                      each.value.destination_topic_ids != null ? ([for id in each.value.destination_topic_ids : length(regexall("^ocid1.*$", id)) > 0 ? id : contains(keys(oci_ons_notification_topic.these),id) ? oci_ons_notification_topic.these[id].id : var.topics_dependency[id].id]) : [],
                      each.value.destination_stream_ids != null ? ([for id in each.value.destination_stream_ids : length(regexall("^ocid1.*$", id)) > 0 ? id : contains(keys(oci_streaming_stream.these),id) ? oci_streaming_stream.these[id].id : var.streams_dependency[id].id]) : []
                   ) : null
  display_name          = each.value.display_name
  is_enabled            = each.value.is_enabled != null ? each.value.is_enabled : true
  metric_compartment_id = each.value.supplied_alarm != null ? (each.value.supplied_alarm.metric_compartment_id != null ? (length(regexall("^ocid1.*$", each.value.supplied_alarm.metric_compartment_id)) > 0 ? each.value.supplied_alarm.metric_compartment_id : var.compartments_dependency[each.value.supplied_alarm.metric_compartment_id].id) : (each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id))) : (each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id))
  namespace             = each.value.supplied_alarm != null ? each.value.supplied_alarm.namespace : local.preconfigured_alarms[each.value.preconfigured_alarm_type].namespace
  query                 = each.value.supplied_alarm != null ? each.value.supplied_alarm.query : local.preconfigured_alarms[each.value.preconfigured_alarm_type].query
  severity              = each.value.supplied_alarm != null ? each.value.supplied_alarm.severity != null ? each.value.supplied_alarm.severity : "CRITICAL" : local.preconfigured_alarms[each.value.preconfigured_alarm_type].severity
  pending_duration      = each.value.supplied_alarm != null ? each.value.supplied_alarm.pending_duration != null ? each.value.supplied_alarm.pending_duration : "PT5M" : local.preconfigured_alarms[each.value.preconfigured_alarm_type].pending_duration
  message_format        = each.value.supplied_alarm != null ? each.value.supplied_alarm.message_format != null ? each.value.supplied_alarm.message_format : "PRETTY_JSON" : local.preconfigured_alarms[each.value.preconfigured_alarm_type].message_format
  repeat_notification_duration = each.value.supplied_alarm != null ? each.value.supplied_alarm.repeat_notification_duration != null ? each.value.supplied_alarm.frequency_for_critical_alarms : "PT4H" :local.preconfigured_alarms[each.value.preconfigured_alarm_type].repeat_frequency_for_critical_alarms
  defined_tags          = each.value.defined_tags != null ? each.value.defined_tags : var.alarms_configuration.default_defined_tags
  freeform_tags         = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.alarms_configuration.default_freeform_tags)
}

resource "oci_ons_notification_topic" "these" {
  for_each       = var.alarms_configuration["topics"] != null ? var.alarms_configuration["topics"] : {}
    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id)
    name           = each.value.name
    description    = each.value.description != null ? each.value.description : each.value.name
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.alarms_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.alarms_configuration.default_freeform_tags)
}

resource "oci_ons_subscription" "these" {
  for_each = { for subs in local.subscriptions : subs.key => { compartment_id = subs.compartment_id,
    protocol     = subs.protocol,
    endpoint     = subs.endpoint,
    topic_id     = subs.topic_id,
    defined_tags = subs.defined_tags,
    freeform_tags = subs.freeform_tags } }
  lifecycle {
    precondition {
      condition     = contains(local.subscription_protocols, upper(each.value.protocol))
      error_message = "VALIDATION FAILURE : \"${each.value.protocol}\" value is invalid for \"protocol\" attribute. Valid values are ${join(", ", local.subscription_protocols)} (case insensitive)."
    }
  }
  compartment_id = each.value.compartment_id
  topic_id       = each.value.topic_id
  endpoint       = each.value.endpoint
  protocol       = each.value.protocol
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags
}

resource "oci_streaming_stream" "these" {
  for_each = var.alarms_configuration["streams"] != null ? var.alarms_configuration["streams"] : {}
    compartment_id     = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.alarms_configuration.default_compartment_id)) > 0 ? var.alarms_configuration.default_compartment_id : var.compartments_dependency[var.alarms_configuration.default_compartment_id].id)
    name               = each.value.name
    partitions         = each.value.num_partitions != null ? each.value.num_partitions : 1
    retention_in_hours = each.value.log_retention_in_hours != null ? each.value.log_retention_in_hours : 24
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.alarms_configuration.default_defined_tags
    freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.alarms_configuration.default_freeform_tags)
}

