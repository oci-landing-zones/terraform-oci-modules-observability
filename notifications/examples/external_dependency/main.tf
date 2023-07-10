# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_object" "compartments" {
  count = var.oci_shared_config_bucket != null ? 1 : 0
    bucket    = var.oci_shared_config_bucket
    namespace = data.oci_objectstorage_namespace.this.namespace
    object    = var.oci_compartments_object
}

module "cislz_notifications" {
  source               = "../../"
  notifications_configuration = var.notifications_configuration
  compartments_dependency = var.oci_shared_config_bucket != null ? jsondecode(data.oci_objectstorage_object.compartments[0].content) : null
}
