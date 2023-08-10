# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Stream pools
resource "oci_streaming_stream_pool" "these" {
  lifecycle {
    create_before_destroy = true
    precondition {
      condition = (each.value.compartment_id != null || var.streams_configuration.default_compartment_id != null)
      error_message = "VALIDATION FAILURE in \"${each.key}\" Stream Pool: You must set either \"compartment_id\" or \"default_compartment_id\"."
    }
  } 
  for_each = var.streams_configuration["stream_pools"] != null ? var.streams_configuration["stream_pools"] : {}
    compartment_id = each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.streams_configuration.default_compartment_id)) > 0 ? var.streams_configuration.default_compartment_id : var.compartments_dependency[var.streams_configuration.default_compartment_id].id)
    name = each.value.name
    dynamic "custom_encryption_key" {
    for_each = each.value.kms_key_id != null ? [length(regexall("^ocid1.*$", each.value.kms_key_id)) > 0 ? each.value.kms_key_id : var.kms_dependency[each.value.kms_key_id].id] : []
      iterator = k
      content {
        kms_key_id = k.value
      }
    }
    dynamic "kafka_settings" {
    for_each = each.value.kafka_settings != null ? [each.value.kafka_settings] : []
      iterator = ks
      content {
        auto_create_topics_enable = coalesce(ks.value.auto_create_topics_enabled,false)
        bootstrap_servers = ks.value.bootstrap_servers
        log_retention_hours = coalesce(ks.value.log_retention_in_hours,"24")
        num_partitions = coalesce(ks.value.num_partitions,"1")
      }
    }
    dynamic "private_endpoint_settings" {
    for_each = each.value.private_endpoint_settings != null ? [each.value.private_endpoint_settings] : []
      iterator = pes
      content {
        subnet_id = length(regexall("^ocid1.*$", pes.value.subnet_id)) > 0 ? pes.value.subnet_id : var.network_dependency[pes.value.subnet_id].id
        private_endpoint_ip = pes.value.private_endpoint_ip
        nsg_ids = pes.value.nsg_ids != null ? ([for id in pes.value.nsg_ids : (length(regexall("^ocid1.*$", id)) > 0 ? id : var.network_dependency[id].id)]) : null
      }
    }
    defined_tags  = each.value.defined_tags != null ? each.value.defined_tags : var.streams_configuration.default_defined_tags
    freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.streams_configuration.default_freeform_tags)
}

resource "oci_streaming_stream" "these" {
  for_each = var.streams_configuration["streams"] != null ? var.streams_configuration["streams"] : {}
  lifecycle {
    precondition {
      condition = (each.value.stream_pool_id != null || each.value.compartment_id != null || var.streams_configuration.default_compartment_id != null)
      error_message = "VALIDATION FAILURE in \"${each.key}\" Stream: You must set either \"stream_pool_id\" (for deploying into a custom Stream Pool), \"compartment_id\" or \"default_compartment_id\" (for deploying into the Default Stream Pool)."
    }
  }  
    compartment_id     = each.value.stream_pool_id == null ? (each.value.compartment_id != null ? (length(regexall("^ocid1.*$", each.value.compartment_id)) > 0 ? each.value.compartment_id : var.compartments_dependency[each.value.compartment_id].id) : (length(regexall("^ocid1.*$", var.streams_configuration.default_compartment_id)) > 0 ? var.streams_configuration.default_compartment_id : var.compartments_dependency[var.streams_configuration.default_compartment_id].id)) : null
    name               = each.value.name
    stream_pool_id     = each.value.stream_pool_id != null ? oci_streaming_stream_pool.these[each.value.stream_pool_id].id : null
    partitions         = each.value.num_partitions != null ? each.value.num_partitions : "1"
    retention_in_hours = each.value.log_retention_in_hours != null ? each.value.log_retention_in_hours : "24"
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.streams_configuration.default_defined_tags
    freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.streams_configuration.default_freeform_tags)
}
