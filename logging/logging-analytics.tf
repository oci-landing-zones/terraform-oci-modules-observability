locals {
  logging_analytics = {
    is_onboarded = true
  }
}


data "oci_log_analytics_namespaces" "logging_analytics_namespaces" {
  compartment_id = var.tenancy_ocid
}

resource "oci_log_analytics_namespace" "this" {
  count = coalesce(var.logging_configuration.onboard_logging_analytics, false) ? 1 : 0
  compartment_id = var.tenancy_ocid
  is_onboarded   = local.logging_analytics.is_onboarded
  namespace      = data.oci_log_analytics_namespaces.logging_analytics_namespaces.namespace_collection[0].items[0].namespace
}

resource "time_sleep" "log_group_propagation_delay" {
  count = coalesce(var.logging_configuration.onboard_logging_analytics, false) ? 1 : 0
  depends_on      = [oci_log_analytics_namespace.this]
  create_duration = "90s"
}