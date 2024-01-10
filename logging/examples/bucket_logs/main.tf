# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "bucket_logging" {
  source                  = "../../"
  tenancy_ocid            =  var.tenancy_ocid
  logging_configuration   = var.logging_configuration
  compartments_dependency = var.external_dependency != null ? merge([for o in data.oci_objectstorage_object.compartments : jsondecode(o.content)]...) : null
}
