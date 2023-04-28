# CIS OCI Landing Zone Service Connector Hub Module

![Landing Zone logo](../landing_zone_300.png)

This module manages service connectors in Oracle Cloud Infrastructure (OCI) based on a single configuration object. Service Connector Hub is a cloud message bus platform that offers a single pane of glass for describing, executing, and monitoring interactions when moving data between OCI services.

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### IAM Permissions

This module requires the following OCI IAM permissions in the compartments where service connectors, logs, policies, buckets and streams are defined. 

For deploying service connectors:
```
Allow group <group> to manage serviceconnectors in compartment <service-connector-compartment-name>
Allow group <group> to read log-content in compartment <log-compartment-name>
Allow group <group> to manage policies in compartment <policy-compartment-name>
```

For deploying buckets:
```
Allow group <group> to manage buckets in compartment <bucket-compartment-name>
Allow group <group> to read objectstorage-namespaces in tenancy
```

For deploying streams:
```
Allow group <group> to manage stream-family in compartment <stream-compartment-name>
```

### Terraform Version < 1.3.x and Optional Object Type Attributes
This module relies on [Terraform Optional Object Type Attributes feature](https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes), which is experimental from Terraform 0.14.x to 1.2.x. It shortens the amount of input values in complex object types, by having Terraform automatically inserting a default value for any missing optional attributes. The feature has been promoted and it is no longer experimental in Terraform 1.3.x.

**As is, this module can only be used with Terraform versions up to 1.2.x**, because it can be consumed by other modules via [OCI Resource Manager service](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/home.htm), that still does not support Terraform 1.3.x.

Upon running *terraform plan* with Terraform versions prior to 1.3.x, Terraform displays the following warning:
```
Warning: Experimental feature "module_variable_optional_attrs" is active
```

Note the warning is harmless. The code has been tested with Terraform 1.3.x and the implementation is fully compatible.

If you really want to use Terraform 1.3.x, in [providers.tf](./providers.tf):
1. Change the terraform version requirement to:
```
required_version = ">= 1.3.0"
```
2. Remove the line:
```
experiments = [module_variable_optional_attrs]
```
## <a name="invoke">How to Invoke the Module</a>

Terraform modules can be invoked locally or remotely. 

For invoking the module locally, just set the module *source* attribute to the module file path (relative path works). The following example assumes the module is two folders up in the file system.
```
module "service_connectors" {
  source = "../.."
  service_connectors_configuration = var.service_connectors_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the service connectors module folder in this repository, as shown:
```
module "service_connectors" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//service_connectors"
  service_connectors_configuration = var.service_connectors_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//service_connectors?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, service connectors are defined using the *service_connectors_configuration* object, that supports the following attributes:
- **default_compartment_ocid**: the default compartment for all resources managed by this module. It can be overriden by *compartment_ocid* attribute in each resource.
- **default_defined_tags**: the default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: the default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.
- **service_connectors**: define the service connectors, their source and target. 
- **buckets**: define the buckets managed by this module that can be used as targets. 
- **streams**: define the streams managed by this module that can be used as targets.

**Note**: Each service connector, bucket and stream are defined as an object whose key must be unique and must not be changed once defined. As a convention, use uppercase strings for the keys.

## Defining the Service Connectors

### Naming Service Connectors
Within the *service_connectors* attribute, use *display_name* attribute to name service connectors and *description* for a text description. 

### Activating Service Connectors
Service connectors are created in "INACTIVE" state by default. Within the *service_connectors* attribute, use *activate* attribute to activate service connectors.

### Defining the Source
Within the *service_connectors* attribute, use the *source* attribute to define the service connector source resources. Within *source*, the following attributes are supported.
- **kind**: the type of source. Supported values are "logging" and "streaming".
- **audit_logs**: a list of objects where audit logs are expected to be found. Multiple audit log locations can be specified using the *cmp_ocid* attribute. Only applicable if *kind* is "logging".
    - **cmp_ocid**: the ocid of the compartment where audit logs are expected to be found. For referring to all audit logs in the tenancy, provide the value "ALL".
- **non_audit_logs**: a list of objects where any logs other than audit logs are expected to be found. Multiple logs can be specified using *cmp_ocid*, *log_group_ocid* and *log_ocid* attributes. Only applicable if *kind* is "logging".
    - **cmp_ocid**: the ocid of the compartment where logs are expected to be found.
    - **log_group_ocid**: the ocid of the log group where logs are expected to be found. It is an optional attribute. If not provided, all logs in *cmp_ocid* are included.
    - **log_ocid**: the ocid of the log. It is an optional attribute. If not provided, all logs in *log_group_ocid* are included.
- **stream_ocid**: the ocid of a stream. Only applicable if *kind* is "streaming".

The following example defines a source that includes tenancy wide audit logs and logs other than audit logs from an specific compartment and log group:
```
source = {
  kind = "logging"
  audit_logs = [
    {cmp_ocid = "ALL"}
  ]
  non_audit_logs = [
    {cmp_ocid = "ocid1.compartment.oc1..aaaaaa...epa", log_group_ocid : "ocid1.loggroup.oc1.iad.amaaaaa...sga"}
  ]
}
```

### Filtering Logging Data
Captured logging data can be filtered before before sent to the target. Within the *service_connectors* attribute, use the *log_rule_filter* attribute to specify a filter. In Service Connector terminology, a log rule filter is known as a Log Filter Task, that only applies to sources of the "logging" kind. It is essentially a boolean expression that filters the data that match the criteria.

The following example defines a rule that filters logging data by VCN ocid and region: 
```
log_rule_filter = "data.vcnId='ocid1.vcn.oc1..amaaaa...mwq' AND data.region='us_ashburn-1'"
```

### Defining the Target
Within the *service_connectors* attribute, use the *target* attribute to define the service connector target resource, i.e., where all source data gets aggregated into. Within *target*, the following attributes are supported:
- **kind**: the type of target. Supported values are "objectstorage", "streaming", "functions", "logginganalytics", and "notifications".
- **bucket_name**: the existing bucket name. Only applicable if kind is "objectstorage".
- **bucket_key** the corresponding bucket key as defined in the *buckets* object map. *bucket_name* has precedence. Only applicable if kind is "objectstorage". 
- **bucket_batch_rollover_size_in_mbs**: the bucket batch rollover size in megabytes. Only applicable if kind is "objectstorage". 
- **bucket_batch_rollover_time_in_ms** : the bucket batch rollover time in milliseconds. Only applicable if kind is "objectstorage". 
- **bucket_object_name_prefix**: the prefix of objects eventually created in the bucket. Only applicable if kind is "objectstorage".
- **stream_ocid**: the existing stream ocid. Only applicable if kind is "streaming".
- **stream_key**: the corresponding stream key as defined in the *streams* object map. *stream_ocid* has precedence. Only applicable if kind is "streaming". 
- **topic_ocid**: the existing topic ocid. Only applicable if kind is "notifications".
- **topic_key**: the corresponding topic key as defined in the *topics* object map. *topic_ocid* has precedence. Only applicable if kind is "notifications".
- **function_ocid**: the existing function ocid. Only applicable if kind is "functions".
- **log_group_ocid**: the existing log group ocid. Only applicable if kind is "logginganalytics".
- **compartment_ocid**: the target resource compartment ocid. Required when using an existing target resource (bucket_name, stream_ocid, function_ocid, or log_group_ocid).
- **policy_name**: the policy name that is created for allowing service connector to push data to target.
- **policy_description**: the policy description.

The following example defines a managed bucket as a target and names the policy that enables Service Connector service to push data to the bucket:
```
target = {
  kind = "objectstorage"
  bucket_key = "SERVICE-CONNECTOR-BUCKET-KEY"
  policy_name = "vision-service-connector-policy"
}
```

## Defining Target Buckets
Within *service_connectors_configuration*, use the *buckets* attribute to define the buckets managed by this module. Within *buckets*, the following attributes are supported:
- **name**: the bucket name
- **compartment_ocid**: the compartment ocid where the bucket is created. *default_compartment_ocid* is used if this is not defined.
- **cis_level**: the CIS level, driving bucket versioning and encryption. Supported values: "1" and "2". cis_level = "1": no versioning, encryption with Oracle managed key. cis_level = 2": versioning enabled, encryption with customer managed key.
- **kms_key_ocid**: the customer managed key ocid. Required if cis_level = "2".
- **defined_tags**: the bucket defined_tags. *default_defined_tags* is used if this is not defined.
- **freeform_tags**: the bucket freeform_tags. *default_freeform_tags* is used if this is not defined.

The following example defines a bucket that is versioned and encrypted with a customer managed key:
```
buckets = {
  SERVICE-CONNECTOR-BUCKET-KEY = { # this key is referred by bucket_key within target attribute
    name = "vision-service-connector-bucket"
    compartment_ocid = "ocid1.compartment.oc1..bbbbb...epa"
    cis_level = "2"
    kms_key_ocid = "ocid1.key.oc1..kkkkk..uir"
  }
} 
```

## Defining Target Streams
Within *service_connectors_configuration*, use the *streams* attribute to define the streams managed by this module. Within *streams*, the following attributes are supported:
- **name**: the stream name
- **compartment_ocid**: the compartment where the stream is created. *default_compartment_ocid* is used if this is not defined.
- **partitions**: the number of stream partitions. Default is "1".  
- **retention_in_hours**: for how long to keep messages in the stream. Default is "24" hours.
- **defined_tags**: the stream defined_tags. *default_defined_tags* is used if this is not defined.
- **freeform_tags**: the stream freeform_tags. *default_freeform_tags* is used if this is not defined.

The following example defines a stream with two partitions and a twelve hour retention period:
```
streams = {
  SERVICE-CONNECTOR-STREAM-KEY = { # this key is referred by stream_key within target attribute
    name = "vision-service-connector-stream"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    partitions = "2"
    retention_in_hours = "12"
  }
}
```

## Defining Target Topics
Within *service_connectors_configuration*, use the *topics* attribute to define the topics managed by this module. Within *topics*, the following attributes are supported:
- **name**: the topic name.
- **description**: the topic description. *name* is used if this is not defined. 
- **compartment_ocid**: the compartment where the topic is created. *default_compartment_ocid* is used if this is not defined.
- **subscriptions**: a list of objects describing the parties that receive topic notifications. Each object is defined by a *protocol* and a list of values for that protocol:
    - **protocol** : one of the following supported values: "EMAIL", "CUSTOM_HTTPS", "PAGERDUTY", "SLACK", "ORACLE_FUNCTIONS", "SMS".
    - **values**: a list of values that are applicable to the chosen protocol. Look at https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/create-subscription.htm for details on protocol requirements.
- **defined_tags**: the topic defined_tags. *default_defined_tags* is used if this is not defined.
- **freeform_tags**: the topic freeform_tags. *default_freeform_tags* is used if this is not defined.

The following example defines a topic that is subscribed by the e-mail address "email.address@example.com":
```
topics = {
  SERVICE-CONNECTOR-TOPIC-KEY : {
    name = "vision-service-connector-topic"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    subscriptions = [
      { protocol = "EMAIL", values : ["email.address@example.com"]}
    ]  
  }
}    
```

## An Example

Here's a sample setting that joins together the snippet examples used above in this document. The service connector aggregates audit and non audit logs in a bucket that is managed by this module.
The audit logs are all audit logs in the tenancy (as denoted by "ALL" in *cmp_ocid*) and logs in the specified *log_group_ocid* within the *source* attribute. The capture logs are filtered by vcn ocid and region. The bucket is defined in the *buckets* attribute and it is a CIS level "2" bucket, meaning it is versioned and encrypted with a customer managed key, specified by *kms_key_ocid* attribute.

```
service_connectors_configuration = {
  default_compartment_ocid = "ocid1.compartment.oc1..aaaaaa...epa"
  service_connectors = {
    SERVICE-CONNECTOR-KEY = {
      display_name = "vision-service-connector"
      source = {
        kind = "logging"
        audit_logs = [
          {cmp_ocid = "ALL"}
        ]
        non_audit_logs = [
          {cmp_ocid = "ocid1.compartment.oc1..aaaaaa...epa", log_group_ocid : "ocid1.loggroup.oc1.iad.amaaaaa...sga"}
        ]
      }
      log_rule_filter = "data.vcnId='ocid1.vcn.oc1..amaaaa...mwq' AND data.region='us_ashburn-1'"
      target = {
        kind = "objectstorage"
        bucket_key = "SERVICE-CONNECTOR-BUCKET-KEY"
        policy_name = "vision-service-connector-policy"
      }
    }  
  }
  buckets = {
    SERVICE-CONNECTOR-BUCKET-KEY = { # this key is referred by bucket_key within target attribute
      name = "vision-service-connector-bucket"
      compartment_ocid = "ocid1.compartment.oc1..bbbbb...epa"
      cis_level = "2"
      kms_key_ocid = "ocid1.key.oc1..kkkkk..uir"
    }
  } 
} 
```

## <a name="related">Related Documentation</a>
- [Overview of Service Connector Hub](https://docs.oracle.com/en-us/iaas/Content/service-connector-hub/overview.htm)
- [Overview of Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)
- [Overview of Streaming](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)
- [Overview of Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)
- [Service Connector Hub in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector)
- [Buckets in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket)
- [Streams in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream)
- [Notification Topics in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic)

## <a name="issues">Known Issues</a>
None.
