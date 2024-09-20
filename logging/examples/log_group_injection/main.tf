# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "vision_logging" {
  source                = "../../"
  tenancy_ocid          = var.tenancy_ocid
  logging_configuration = var.logging_configuration
}
