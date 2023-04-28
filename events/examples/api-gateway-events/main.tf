# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "api_gateway_events" {
  source = "../../"
  events_configuration = var.events_configuration
}