# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  count = var.oci_shared_config_bucket != null ? 1 : 0
    compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_object" "compartments" {
  count = var.oci_shared_config_bucket != null && var.oci_compartments_object != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket
    namespace = data.oci_objectstorage_namespace.this[0].namespace
    object    = var.oci_compartments_object
}

data "oci_objectstorage_object" "topics" {
  count = var.oci_shared_config_bucket != null && var.oci_topics_object != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket
    namespace = data.oci_objectstorage_namespace.this[0].namespace
    object    = var.oci_topics_object
}

module "vision_alarms" {
  source               = "../../"
  alarms_configuration = var.alarms_configuration
  compartments_dependency = var.oci_compartments_object != null ? jsondecode(data.oci_objectstorage_object.compartments[0].content) : null
  topics_dependency = var.oci_topics_object != null ? jsondecode(data.oci_objectstorage_object.topics[0].content) : null
}
