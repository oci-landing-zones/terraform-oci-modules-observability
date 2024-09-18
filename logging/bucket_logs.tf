# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  bucket_logs_compartment_ids = flatten([
    for bl_key, bl_value in (var.logging_configuration.bucket_logs != null ? var.logging_configuration.bucket_logs : {}) : [
      for cmp_id in bl_value.target_compartment_ids : [(length(regexall("^ocid1.*$", cmp_id)) > 0 ? cmp_id : var.compartments_dependency[cmp_id].id)]
    ]
  ])

  bucket_logs = flatten([
    for bl_key, bl_value in (var.logging_configuration.bucket_logs != null ? var.logging_configuration.bucket_logs : {}) : [
      for cmp_id in bl_value.target_compartment_ids : [
        for bucket in data.oci_objectstorage_bucket_summaries.these[(length(regexall("^ocid1.*$", cmp_id)) > 0 ? cmp_id : var.compartments_dependency[cmp_id].id)].bucket_summaries : {
          key = upper("${bl_key}-${replace(bucket.name,"/\\s+/","-")}")
          category = bl_value.category
          resource_id = bucket.name
          service = "objectstorage"
          name = "${replace(bucket.name,"/\\s+/","-")}-${bl_value.category}-log"
          log_group_id = bl_value.log_group_id
          is_enabled = bl_value.is_enabled
          retention_duration = bl_value.retention_duration
          defined_tags = bl_value.defined_tags
          freeform_tags = bl_value.freeform_tags
        }  
      ]
    ]
  ])

}

data "oci_objectstorage_namespace" "this" {
  count = var.logging_configuration.bucket_logs != null ? 1 : 0  
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_bucket_summaries" "these" {
  for_each = toset(local.bucket_logs_compartment_ids)
    compartment_id = each.key
    namespace = data.oci_objectstorage_namespace.this[0].namespace
}

resource "oci_logging_log" "bucket_logs" {
  for_each = { for v in local.bucket_logs : v.key => {
                category = v.category
                resource_id = v.resource_id
                service = v.service
                name = v.name
                log_group_id = v.log_group_id
                is_enabled = v.is_enabled
                retention_duration = v.retention_duration
                defined_tags = v.defined_tags
                freeform_tags = v.freeform_tags }}
    display_name = each.value.name
    log_group_id = contains(keys(var.logging_configuration.log_groups),each.value.log_group_id) ? oci_logging_log_group.these[each.value.log_group_id].id : (length(regexall("^ocid1.*$", each.value.log_group_id)) > 0 ? each.value.log_group_id : var.log_groups_dependency[each.value.log_group_id].id)
    log_type     = "SERVICE"
    configuration {
      #compartment_id = each.value.compartment_id
      source {
        category    = each.value.category
        resource    = each.value.resource_id
        service     = each.value.service
        source_type = "OCISERVICE"
      }
    }
    is_enabled         = coalesce(each.value.is_enabled,true) 
    retention_duration = coalesce(each.value.retention_duration, 60)
    defined_tags       = each.value.defined_tags != null ? each.value.defined_tags : var.logging_configuration.default_defined_tags
    freeform_tags = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.logging_configuration.default_freeform_tags)
}

