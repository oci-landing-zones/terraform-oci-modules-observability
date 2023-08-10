# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  service_connectors_configuration = {
    default_compartment_id : var.service_connector_compartment_ocid
    service_connectors : {
      SIEM-INTEGRATION-SERVICE-CONNECTOR : {
        display_name : "vision-siem-integration-service-connector"
        source : {
          kind : "logging"
          audit_logs : [
            {cmp_id : "ALL"} # "ALL" means all tenancy audit logs. Only applicable if kind = "logging".
          ]   
          non_audit_logs : [for ocid in var.logs_compartment_ocids : 
            {cmp_id = ocid} # Bucket logs, flow logs compartment - 
          ] 
        }
        target : {
          kind : "streaming"
          stream_id : module.vision_streams.streams["SIEM-INTEGRATION-STREAM"].id,
          policy_name : "vision-siem-integration-service-connector-policy" # The policy name that is created allowing the service connector to push data to bucket.
          compartment_id = module.vision_streams.streams["SIEM-INTEGRATION-STREAM"].compartment_id
        }
      }
    }
  } 
} 

module "vision_connector" {
  source         = "../../service-connectors/"
  providers = {
    oci = oci
    oci.home = oci.home
  }
  tenancy_ocid     = var.tenancy_ocid
  service_connectors_configuration = local.service_connectors_configuration
}