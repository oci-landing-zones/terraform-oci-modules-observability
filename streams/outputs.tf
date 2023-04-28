# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "streams" {
  description = "The streams."
  value = var.enable_output ? oci_streaming_stream.these : null
}

output "stream_pools" {
  description = "The (custom) stream pools."
  value = var.enable_output ? oci_streaming_stream_pool.these : null
}

output "default_stream_pools" {
  description = "The default stream pools."
  value = var.enable_output ? oci_streaming_stream_pool.defaults : null
}
