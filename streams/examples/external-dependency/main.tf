# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  count = var.oci_shared_config_bucket_name != null ? 1 : 0
    compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_object" "compartments" {
  count = var.oci_shared_config_bucket_name != null && var.oci_compartments_object_name != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket_name
    namespace = data.oci_objectstorage_namespace.this[0].namespace
    object    = var.oci_compartments_object_name
}

data "oci_objectstorage_object" "keys" {
  count = var.oci_shared_config_bucket_name != null && var.oci_kms_object_name != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket_name
    namespace = data.oci_objectstorage_namespace.this[0].namespace
    object    = var.oci_kms_object_name
}

data "oci_objectstorage_object" "network" {
  count = var.oci_shared_config_bucket_name != null && var.oci_network_object_name != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket_name
    namespace = data.oci_objectstorage_namespace.this[0].namespace
    object    = var.oci_network_object_name
}

module "vision_streams" {
  source                  = "../../"
  streams_configuration   = var.streams_configuration
  compartments_dependency = var.oci_compartments_object_name != null ? jsondecode(data.oci_objectstorage_object.compartments[0].content) : null
  kms_dependency          = var.oci_kms_object_name != null ? jsondecode(data.oci_objectstorage_object.keys[0].content) : null
  network_dependency      = var.oci_network_object_name != null ? jsondecode(data.oci_objectstorage_object.network[0].content) : null
}
