# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_group" {
  value = module.vision_logging.log_groups
}

output "service_logs" {
  value = module.vision_logging.service_logs
}

output "custom_logs" {
  value = module.vision_logging.custom_logs
}