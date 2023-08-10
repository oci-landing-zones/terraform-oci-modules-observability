# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  subscriptions = flatten([
    for topic_key, topic in (var.events_configuration["topics"] != null ? var.events_configuration["topics"] : {}) : [
      for subs in (topic["subscriptions"] != null ? topic["subscriptions"] : []) : [
        for value in subs["values"] : {
          key = "${topic_key}.${value}"
          compartment_id = topic.compartment_id != null ? (length(regexall("^ocid1.*$", topic.compartment_id)) > 0 ? topic.compartment_id : var.compartments_dependency[topic.compartment_id].id) : (length(regexall("^ocid1.*$", var.events_configuration.default_compartment_id)) > 0 ? var.events_configuration.default_compartment_id : var.compartments_dependency[var.events_configuration.default_compartment_id].id)
          protocol = upper(subs.protocol)
          endpoint = value
          topic_id = oci_ons_notification_topic.these[topic_key].id
          defined_tags = subs.defined_tags != null ? subs.defined_tags : topic.defined_tags != null ? topic.defined_tags : var.events_configuration.default_defined_tags
          freeform_tags = merge(local.cislz_module_tag, subs.freeform_tags != null ? subs.freeform_tags : topic.freeform_tags != null ? topic.freeform_tags : var.events_configuration.default_freeform_tags)
        } 
      ]   
    ]
  ])

  subscription_protocols = ["EMAIL","CUSTOM_HTTPS","SLACK","PAGERDUTY","ORACLE_FUNCTIONS","SMS"]

  data_element_attributes = ["compartmentId","compartmentName","resourceName","resourceId","availabilityDomain"]

  filters = {for key, rule in var.events_configuration["event_rules"] : key => merge(rule.tags_filter != null ? {for tag_filter in rule.tags_filter : "definedTags" => {(tag_filter.namespace) : { for tag in tag_filter.tags : (tag.name) => tag.value }}}:{}, 
                                                                                      rule.attributes_filter != null ? {for attr_filter in rule.attributes_filter : attr_filter.attr => attr_filter.value if contains(local.data_element_attributes,attr_filter.attr)}:{},
                                                                                      rule.attributes_filter != null ? {for attr_filter in rule.attributes_filter : "additionalDetails" => {(attr_filter.attr) : attr_filter.value} if !contains(local.data_element_attributes,attr_filter.attr)}:{})

  }
  #-- The filters local variable is for easing filters processing in oci_events_rule condition attribute. 
  #-- Here we are processing tags_filter and attributes_filter input attributes, by building a Terraform map of objects made by tags and attributes filters as expected by the Events service. 
  #-- It results in a structure like this:
  #-- filters      = {
  #     IDENTITY-SIGNON-EVENTS-KEY = {
  #         compartmentId   = [
  #             "ocid1.compartment.oc1..aaaaaaaaw22engd4ipk52nvsfzxeroee4uskaryijy6l5omfh7syza2vf4ja",
  #             "ocid1.compartment.oc1..aaaaaaaaw22engd4ipk52nvsfzxeroee4uskaryijy6l5omfh7syza2vf4ja",
  #          ]
  #         compartmentName = [
  #             "cislz-network-cmp",
  #          ]
  #         definedTags     = {
  #             OracleInternalReserved = {
  #                 CostCenter = "2"
  #                 OwnerEmail = "josh.hammer@oracle.com"
  #              }
  #          }
  #      }
  #     NETWORK-EVENTS-KEY         = {
  #         compartmentId = [
  #             "ocid1.compartment.oc1..aaaaaaaaw22engd4ipk52nvsfzxeroee4uskaryijy6l5omfh7syza2vf4ja",
  #             "ocid1.compartment.oc1..aaaaaaaaw22engd4ipk52nvsfzxeroee4uskaryijy6l5omfh7syza2vf4ja",
  #          ]
  #         definedTags   = {
  #             OracleInternalReserved = {
  #                 CostCenter = "1"
  #                 OwnerEmail = "andre.correa@oracle.com"
  #              }
  #          }
  #      }
  #  }
}  

resource "oci_events_rule" "these" {
  for_each = var.events_configuration["event_rules"]
    lifecycle {
      precondition {
        #-- This precondition checks if values in preconfigured_events_categories attributes are valid.
        condition = each.value.preconfigured_events_categories != null ? length(setintersection(keys(local.preconfigured_events),[for category in each.value.preconfigured_events_categories : lower(category)])) == length([for category in each.value.preconfigured_events_categories : lower(category)]) : true
        error_message = "VALIDATION FAILURE : \"${each.value.preconfigured_events_categories != null ? join(",",setsubtract([for category in each.value.preconfigured_events_categories : lower(category)],keys(local.preconfigured_events))) : ""}\" value is invalid for \"preconfigured_events_categories\" attribute. Valid values are ${join(", ",keys(local.preconfigured_events))} (case insensitive)."
      }
    }

    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.events_configuration.default_compartment_id)) > 0 ? var.events_configuration.default_compartment_id : var.compartments_dependency[var.events_configuration.default_compartment_id].id)
    display_name   = each.value.event_display_name
    description    = each.value.event_description != null ? each.value.event_description : each.value.event_display_name
    condition      = each.value.supplied_events != null ? jsonencode({"eventType":each.value.supplied_events,"data":local.filters[each.key]}) : jsonencode({"eventType":flatten(concat([for category in each.value.preconfigured_events_categories : local.preconfigured_events[lower(category)].conditions])),"data":local.filters[each.key]})
    is_enabled     = each.value.is_enabled != null ? each.value.is_enabled : true
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.events_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.events_configuration.default_freeform_tags)
    actions {
      dynamic "actions" {
        for_each = each.value.destination_topic_ids != null ? each.value.destination_topic_ids : []
        content {
          action_type = "ONS"
          is_enabled  = true
          description = "Events are published into a topic."
          topic_id    = length(regexall("^ocid1.*$", actions.value)) > 0 ? actions.value : contains(keys(oci_ons_notification_topic.these),actions.value) ? oci_ons_notification_topic.these[actions.value].id : var.topics_dependency[actions.value].id
          stream_id   = null
          function_id = null
        }  
      }
      dynamic "actions" {
        for_each = each.value.destination_stream_ids != null ? each.value.destination_stream_ids : []
        content {
          action_type = "OSS"
          is_enabled  = true
          description = "Events are sent to a stream."
          topic_id    = null
          stream_id   = length(regexall("^ocid1.*$", actions.value)) > 0 ? actions.value : contains(keys(oci_streaming_stream.these),actions.value) ? oci_streaming_stream.these[actions.value].id : var.streams_dependency[actions.value].id
          function_id = null
        }  
      }
      dynamic "actions" {
        for_each = each.value.destination_function_ids != null ? each.value.destination_function_ids : []
        content {
          action_type = "FAAS"
          is_enabled  = true
          description = "Events are sent to a function."
          topic_id    = null
          stream_id   = null
          function_id = length(regexall("^ocid1.*$", actions.value)) > 0 ? actions.value : var.functions_dependency[actions.value].id
        }  
      } 
    }
}

resource "oci_ons_notification_topic" "these" {
  for_each = var.events_configuration["topics"] != null ? var.events_configuration["topics"] : {}
    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.events_configuration.default_compartment_id)) > 0 ? var.events_configuration.default_compartment_id : var.compartments_dependency[var.events_configuration.default_compartment_id].id)
    name           = each.value.name
    description    = each.value.description != null ? each.value.description : each.value.name
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.events_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.events_configuration.default_freeform_tags) 
}

resource "oci_ons_subscription" "these" {
  for_each = { for subs in local.subscriptions : subs.key => {compartment_id = subs.compartment_id,
                                                              protocol = subs.protocol,
                                                              endpoint = subs.endpoint,
                                                              topic_id = subs.topic_id,
                                                              defined_tags = subs.defined_tags,
                                                              freeform_tags = subs.freeform_tags}}
    lifecycle {
      precondition {
        condition = contains(local.subscription_protocols,upper(each.value.protocol))
        error_message = "VALIDATION FAILURE : \"${each.value.protocol}\" value is invalid for \"protocol\" attribute. Valid values are ${join(", ",local.subscription_protocols)} (case insensitive)."
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
  for_each = var.events_configuration["streams"] != null ? var.events_configuration["streams"] : {}
    compartment_id     = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.events_configuration.default_compartment_id)) > 0 ? var.events_configuration.default_compartment_id : var.compartments_dependency[var.events_configuration.default_compartment_id].id)
    name               = each.value.name
    partitions         = each.value.num_partitions != null ? each.value.num_partitions : 1
    retention_in_hours = each.value.log_retention_in_hours != null ? each.value.log_retention_in_hours : 24
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.events_configuration.default_defined_tags
    freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.events_configuration.default_freeform_tags)
}