# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  
  home_region_events_configuration = {
    default_compartment_ocid : var.tenancy_ocid
    event_rules : {
      CLOUDGUARD-EVENTS-RULE-KEY : {
        preconfigured_events_categories : ["cloudguard"]
        event_display_name : "vision-siem-integration-cloud-guard-events"
        event_description : "Events rule to capture Cloud Guard problems that are detected, dismissed or resolved."
        attributes_filter : [{
          attr : "riskLevel"
          value : ["CRITICAL","HIGH"]
        }]
        actions_streams : {
          existing_stream_ocids : [module.vision_streams.streams["SIEM-INTEGRATION-STREAM-KEY"].id]
        }
      }
    }
  }

  regional_events_configuration = {
    default_compartment_ocid : var.tenancy_ocid
    event_rules = { 
      DATASAFE-EVENTS-RULE-KEY : {
        supplied_events = ["com.oraclecloud.datasafe.generateauditalert","com.oraclecloud.datasafe.securityassessmentdriftfrombaseline"]
        event_display_name = "vision-siem-integration-data-safe-events"
        event_description = "Events rule to capture Data Safe events."
        actions_streams = {
          existing_stream_ocids = [module.vision_streams.streams["SIEM-INTEGRATION-STREAM-KEY"].id]
        }
      }
    }
  }
}  

module "vision_home_region_events" {
  source = "../../events/"
  providers = { oci = oci.home }
  events_configuration = local.home_region_events_configuration
}

module "vision_events" {
  source = "../../events/"
  events_configuration = local.regional_events_configuration
}
