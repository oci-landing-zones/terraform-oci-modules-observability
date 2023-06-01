# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Stream pools for streams that DO refer to a specific stream pool.
resource "oci_streaming_stream_pool" "these" {
  lifecycle {
    create_before_destroy = true
  }
  for_each = var.streams_configuration["stream_pools"] != null ? var.streams_configuration["stream_pools"] : {}
    compartment_id = each.value.compartment_ocid != null ? each.value.compartment_ocid : var.streams_configuration.default_compartment_ocid
    name = each.value.name
    dynamic "custom_encryption_key" {
    for_each = each.value.kms_key_ocid != null ? [each.value.kms_key_ocid] : []
      iterator = k
      content {
        kms_key_id = k.value
      }
    }
    dynamic "kafka_settings" {
    for_each = each.value.kafka_settings != null ? [each.value.kafka_settings] : []
      iterator = ks
      content {
        auto_create_topics_enable = ks.value.auto_create_topics_enabled != null ? ks.value.auto_create_topics_enabled : false
        bootstrap_servers = ks.value.bootstrap_servers != null ? ks.value.bootstrap_servers : null
        log_retention_hours = ks.value.log_retention_in_hours != null ? ks.value.log_retention_in_hours : "24"
        num_partitions = ks.value.num_partitions != null ? ks.value.num_partitions : "1"
      }
    }
    dynamic "private_endpoint_settings" {
    for_each = each.value.private_endpoint_settings != null ? [each.value.private_endpoint_settings] : []
      iterator = pes
      content {
        subnet_id = pes.value.subnet_ocid != null ? pes.value.subnet_ocid : null
        private_endpoint_ip = pes.value.private_endpoint_ip != null ? pes.value.private_endpoint_ip : null
        nsg_ids = pes.value.nsg_ocids != null ? pes.value.nsg_ocids : null
      }
    }
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.streams_configuration.default_defined_tags
    freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.streams_configuration.default_freeform_tags)
}

## Stream pools for streams that DO NOT refer to a specific stream pool.
resource "oci_streaming_stream_pool" "defaults" {
  lifecycle {
    create_before_destroy = true
  }
  for_each = var.streams_configuration["streams"] != null ? {for k, v in var.streams_configuration["streams"]: k => v if v.stream_pool_key == null} : {}
    compartment_id = each.value.compartment_ocid != null ? (length(regexall("^ocid1.*$", each.value.compartment_ocid)) > 0 ? each.value.compartment_ocid : jsondecode(var.dependencies)[each.value.compartment_ocid].id) : (length(regexall("^ocid1.*$", var.streams_configuration.default_compartment_ocid)) > 0 ? var.streams_configuration.default_compartment_ocid : jsondecode(var.dependencies)[var.streams_configuration.default_compartment_ocid].id)
    name           = "${each.value.name}-default-pool"
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.streams_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.streams_configuration.default_freeform_tags)
}

resource "oci_streaming_stream" "these" {
  for_each = var.streams_configuration["streams"] != null ? var.streams_configuration["streams"] : {}
    ## if the stream is meant to belong to a stream pool, compartment_id must not be set.
    compartment_id     = null #each.value.stream_pool_key == null ? each.value.compartment_ocid != null ? each.value.compartment_ocid : var.streams_configuration.default_compartment_ocid : null
    name               = each.value.name
    stream_pool_id     = each.value.stream_pool_key == null ? oci_streaming_stream_pool.defaults[each.key].id : oci_streaming_stream_pool.these[each.value.stream_pool_key].id  
    partitions         = each.value.num_partitions != null ? each.value.num_partitions : "1"
    retention_in_hours = each.value.log_retention_in_hours != null ? each.value.log_retention_in_hours : "24"
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.streams_configuration.default_defined_tags
    freeform_tags      = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.streams_configuration.default_freeform_tags)
}
