# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "events" {
  value = module.api_gateway_events.events
}

output "topics" {
  value = module.api_gateway_events.topics
}

output "streams" {
  value = module.api_gateway_events.streams
}