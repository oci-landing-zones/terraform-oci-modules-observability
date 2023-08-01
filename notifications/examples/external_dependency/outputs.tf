# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_objectstorage_object" "this" {
  bucket = var.oci_shared_config_bucket_name
  content = jsonencode(module.cislz_notifications.topics)
  namespace = data.oci_objectstorage_namespace.this.namespace
  object = var.oci_topics_object_name
}

output "topics" {
  value = module.cislz_notifications.topics
}
