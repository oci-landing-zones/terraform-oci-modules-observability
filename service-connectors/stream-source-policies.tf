# Copyright (c) 2026 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  stream_source_compartments = {
    for k, sc in coalesce(var.service_connectors_configuration.service_connectors, {}) : k => coalesce(
      sc.source.compartment_id,
      try(var.streams_dependency[sc.source.stream_id].compartment_id, null),
      sc.compartment_id,
      var.service_connectors_configuration.default_compartment_id
    ) if lower(sc.source.kind) == local.SOURCE_STREAMING && lower(sc.target.kind) == local.TARGET_LOGGING_ANALYTICS
  }
}

resource "oci_identity_policy" "stream_sources" {
  for_each       = local.stream_source_compartments
  provider       = oci.home
  name           = "service-connector-${each.key}-stream-source-policy"
  description    = "Allow the service connector to consume its source stream."
  compartment_id = startswith(each.value, "ocid1.") ? each.value : var.compartments_dependency[each.value].id
  statements = [<<EOF
Allow any-user to {STREAM_READ, STREAM_CONSUME} in compartment id ${startswith(each.value, "ocid1.") ? each.value : var.compartments_dependency[each.value].id} where all {
  request.principal.type='serviceconnector',
  request.principal.id='${oci_sch_service_connector.these[each.key].id}',
  request.principal.compartment.id='${oci_sch_service_connector.these[each.key].compartment_id}',
  target.stream.id='${oci_sch_service_connector.these[each.key].source[0].stream_id}'
}
EOF
  ]
  defined_tags  = var.service_connectors_configuration.service_connectors[each.key].defined_tags != null ? var.service_connectors_configuration.service_connectors[each.key].defined_tags : var.service_connectors_configuration.default_defined_tags
  freeform_tags = merge(local.cislz_module_tag, var.service_connectors_configuration.service_connectors[each.key].freeform_tags != null ? var.service_connectors_configuration.service_connectors[each.key].freeform_tags : var.service_connectors_configuration.default_freeform_tags)
}
