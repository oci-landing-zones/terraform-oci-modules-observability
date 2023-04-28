# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "vision_events" {
  source = "../../"
  events_configuration = var.events_configuration
}

module "vision_home_region_events" {
  source = "../../"
  providers = { oci = oci.home }
  events_configuration = var.home_region_events_configuration
}