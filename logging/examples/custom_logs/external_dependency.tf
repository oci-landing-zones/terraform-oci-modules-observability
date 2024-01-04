# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  count = var.external_dependency != null ? 1 : 0
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_object" "compartments" {
  count = var.external_dependency != null ? length(var.external_dependency.cmp_dependency) : 0
  bucket    = var.external_dependency.bucket_name
  namespace = data.oci_objectstorage_namespace.this[0].namespace
  object    = var.external_dependency.cmp_dependency[count.index]
}