# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  streams_configuration = {
    default_compartment_id : var.stream_compartment_ocid
    streams : {
      SIEM-INTEGRATION-STREAM : {
        name : "vision-siem-integration-stream"
      }
    }
  }
}

module "vision_streams" {
  source               = "../../streams/"
  streams_configuration = local.streams_configuration
}
