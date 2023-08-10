# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "events" {
  value = merge(module.vision_events.events,module.vision_home_region_events.events)
}

output "topics" {
  value = merge(module.vision_events.topics,module.vision_home_region_events.topics)
}

output "streams" {
  value = module.vision_events.streams
}