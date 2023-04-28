locals {
    
  policy_statements = { for key, sc in var.service_connectors_configuration.service_connectors : key => {  
  
    grants = lower(sc.target.kind) == local.TARGET_OBJECT_STORAGE ? [
      <<EOF
          Allow any-user to manage objects in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.target.bucket_key != null ? oci_objectstorage_bucket.these[sc.target.bucket_key].compartment_id : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type='serviceconnector',
          target.bucket.name= '${sc.target.bucket_name != null ? sc.target.bucket_name : oci_objectstorage_bucket.these[sc.target.bucket_key].name}',
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}' }
      EOF
      ] : lower(sc.target.kind) == local.TARGET_STREAMING ? [
      <<EOF
          Allow any-user to use stream-push in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.target.stream_key != null ? oci_streaming_stream.these[sc.target.stream_key].compartment_id : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type='serviceconnector',
          target.stream.id='${sc.target.stream_ocid != null ? sc.target.stream_ocid : oci_streaming_stream.these[sc.target.stream_key].id}',
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}' }
      EOF
      ] : lower(sc.target.kind) == local.TARGET_FUNCTIONS ? [
      <<EOF
          Allow any-user to use fn-function in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type='serviceconnector',     
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}'}
      EOF
      ,
      <<EOF2
          Allow any-user to use fn-invocation in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type='serviceconnector',     
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}' }
      EOF2
      ] : lower(sc.target.kind) == local.TARGET_LOGGING_ANALYTICS ? [
      <<EOF
          Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type='serviceconnector',
          target.loganalytics-log-group.id='${sc.target.log_group_ocid}',
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}' }
      EOF
      ] : lower(sc.target.kind) == local.TARGET_NOTIFICATIONS ? [
      <<EOF
          Allow any-user to use ons-topics in compartment id ${sc.target.compartment_ocid != null ? sc.target.compartment_ocid : sc.target.topic_key != null ? oci_ons_notification_topic.these[sc.target.topic_key].compartment_id : sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid} where all {
          request.principal.type= 'serviceconnector', 
          request.principal.compartment.id='${sc.compartment_ocid != null ? sc.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid}'}
      EOF  
      ] : []
  }}
}

#--------------------------------------------------
#--- SCH policy resource:
#--- 1. oci_identity_policy
#--------------------------------------------------
resource "oci_identity_policy" "these" {
  for_each = var.service_connectors_configuration.service_connectors
    lifecycle {
      precondition {
        condition = contains(local.targets,lower(each.value.target.kind))
        error_message = "VALIDATION FAILURE : \"${each.value.target.kind}\" value is invalid for \"target kind\" attribute in \"${each.key}\" service connector. Valid values are ${join(", ",local.targets)} (case insensitive)."
      }
    }
    provider       = oci.home
    name           = each.value.target.policy_name != null ? each.value.target.policy_name : "service-connector-${lower(each.value.target.kind)}-policy"
    description    = each.value.target.policy_description != null ? each.value.target.policy_description : "Policy allowing Service Connector Hub to push data to ${lower(each.value.target.kind)}."
    compartment_id = each.value.target.compartment_ocid != null ? each.value.target.compartment_ocid : each.value.compartment_ocid != null ? each.value.compartment_ocid : var.service_connectors_configuration.default_compartment_ocid
    statements     = local.policy_statements[each.key].grants
    defined_tags   = each.value.defined_tags != null ? each.value.defined_tags : var.service_connectors_configuration.default_defined_tags
    freeform_tags  = merge(local.cislz_module_tag, each.value.freeform_tags != null ? each.value.freeform_tags : var.service_connectors_configuration.default_freeform_tags)
}