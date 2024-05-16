# ###################################################################################################### #
# Copyright (c) 2024 Oracle and/or its affiliates, All rights reserved.                                  #
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl. #
# ###################################################################################################### #

resource "oci_announcements_service_announcement_subscription" "these" {
  for_each       = var.notifications_configuration.announcement_subscriptions != null ? var.notifications_configuration.announcement_subscriptions : {}
  compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", topic.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.notifications_configuration.default_compartment_id)) > 0 ? var.notifications_configuration.default_compartment_id : var.compartments_dependency[var.notifications_configuration.default_compartment_id].id)
  display_name   = each.value.display_name
  ons_topic_id   = each.value.notification_topic_id
  description    = each.value.description
  defined_tags          = merge(each.value.defined_tags, var.notifications_configuration.default_defined_tags)
  freeform_tags         = merge(each.value.freeform_tags, var.notifications_configuration.default_freeform_tags)
  preferred_language    = each.value.preferred_language
  preferred_time_zone   = each.value.preferred_time_zone
}

resource "oci_announcements_service_announcement_subscriptions_filter_group" "these" {
  for_each                     = var.notifications_configuration.announcement_subscriptions.filter_groups != null ? var.notifications_configuration.announcement_subscriptions.filter_groups : {}
  announcement_subscription_id = oci_announcements_service_announcement_subscription.these.id
  name                         = each.value.name
  dynamic "filters" {
    for_each = toset(each.value.filter_value)
    content {
      type  = each.value.filter_type
      value = filters.key
    }
  }
}