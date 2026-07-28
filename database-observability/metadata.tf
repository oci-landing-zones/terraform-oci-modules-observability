# Copyright (c) 2026 Contributors to oci-dbman-opsi.
# Licensed under the Universal Permissive License v 1.0.

locals {
  module_release = fileexists("${path.module}/../release.txt") ? trimspace(file("${path.module}/../release.txt")) : null
  module_tags = {
    "ocilz-terraform-module" = local.module_release != null ? "${var.module_name}/${local.module_release}" : var.module_name
  }
}
