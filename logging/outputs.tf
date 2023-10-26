# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_groups" {
  description = "The log groups."
  value = var.enable_output ? oci_logging_log_group.these : null
}

output "service_logs" {
  description = "The logs."
  value = var.enable_output ? merge(oci_logging_log.these,oci_logging_log.flow_logs,oci_logging_log.bucket_logs) : null
}

output "custom_logs" {
  description = "The custom logs."
  value = var.enable_output ? oci_logging_log.these_custom : null
}

output "custom_logs_agent_config" {
  description = "The agent configurations for custom logs."
  value = var.enable_output ? oci_logging_unified_agent_configuration.these : null
}