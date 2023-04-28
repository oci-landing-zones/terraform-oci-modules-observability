# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  subscriptions = flatten([
    for topic_key, topic in (var.service_connectors_configuration["topics"] != null ? var.service_connectors_configuration["topics"] : {}) : [
      for subs in (topic["subscriptions"] != null ? topic["subscriptions"] : []) : [
        for value in subs["values"] : {
          key = "${topic_key}.${value}"
          compartment_id = subs.compartment_ocid != null ? subs.compartment_ocid : topic.compartment_ocid != null ? topic.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid
          protocol = upper(subs.protocol)
          endpoint = value
          topic_id = oci_ons_notification_topic.these[topic_key].id
          defined_tags = subs.defined_tags != null ? subs.defined_tags : topic.defined_tags != null ? topic.defined_tags : var.service_connectors_configuration.default_defined_tags
          freeform_tags = merge(local.cislz_module_tag, subs.freeform_tags != null ? subs.freeform_tags : topic.freeform_tags != null ? topic.freeform_tags : var.service_connectors_configuration.default_freeform_tags)
        } 
      ]   
    ]
  ])
}

resource "oci_ons_notification_topic" "these" {
  for_each = var.service_connectors_configuration["topics"] != null ? var.service_connectors_configuration["topics"] : {}
    compartment_id = each.value.compartment_ocid != null ? each.value.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid
    name           = each.value.name
    description    = each.value.description != null ? each.value.description : each.value.name
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.service_connectors_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.service_connectors_configuration.default_freeform_tags) 
}

resource "oci_ons_subscription" "these" {
  for_each = { for subs in local.subscriptions : subs.key => {compartment_id = subs.compartment_ocid,
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

