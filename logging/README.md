# OCI Landing Zone Logging Module

![Landing Zone logo](../landing_zone_300.png)

This module manages log groups and logs in Oracle Cloud Infrastructure (OCI) based on a single configuration object. Logging provides access to logs from Oracle Cloud Infrastructure resources. These logs include critical diagnostic information that describes how resources are performing and being accessed. 

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### Terraform Version >= 1.3.0

This module requires Terraform binary version 1.3.0 or greater, as it relies on Optional Object Type Attributes feature. The feature shortens the amount of input values in complex object types, by having Terraform automatically inserting a default value for any missing optional attributes.

### IAM Permissions

This module requires the following OCI IAM permissions in compartments where log groups and logs are managed. Additionally, extra permissions are needed depending on the resource that logging is being enabled for.

For deploying log groups and logs in general:
```
Allow group <group> to manage logging-family in compartment <log-group-compartment-name>
```

For deploying flow logs (using the *service_logs* attribute. See [Module Functioning](#functioning)):
```
Allow group <group> to manage subnets in compartment <subnet-compartment-name> where request.permission = 'SUBNET_UPDATE'
```

For deploying flow logs (using the *flow_logs* attribute. See [Module Functioning](#functioning)):
```
Allow group <group> to inspect compartments in tenancy
Allow group <group> to manage subnets in compartment <subnet-compartment-name> where request.permission = 'SUBNET_UPDATE'
```

For deploying bucket logs (using the *service_logs* attribute. See [Module Functioning](#functioning)):
```
Allow group <group> to use buckets in compartment <bucket-compartment-name>
```

For deploying bucket logs (using the *bucket_logs* attribute. See [Module Functioning](#functioning)):
```
Allow group <group> to inspect compartments in tenancy
Allow group <group> to read objectstorage-namespaces in tenancy
Allow group <group> to use buckets in compartment <bucket-compartment-name>
```

## <a name="invoke">How to Invoke the Module</a>

Terraform modules can be invoked locally or remotely. 

For invoking the module locally, just set the module *source* attribute to the module file path (relative path works). The following example assumes the module is two folders up in the file system.
```
module "logging" {
  source = "../.."
  tenancy_ocid = var.tenancy_ocid # for deploying bucket logs using bucket_logs attribute.
  logging_configuration = var.logging_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the logging module folder in this repository, as shown:
```
module "logging" {
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability/logging"
  tenancy_ocid = var.tenancy_ocid # for deploying bucket logs using bucket_logs attribute.
  logging_configuration = var.logging_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability//logging?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, log groups and logs are defined using the top-level *logging_configuration* variable. It contains a set of attributes starting with the prefix *default_* and a set of attributes to define any number of log groups and logs. The *default_* attribute values are applied to all log groups and logs, unless overriden at the object level. **The module supports defining service and custom logs for single resources or for a set of resources within specified compartments**. For defining logs to single resources, use either *service_logs* or *custom_logs* attributes. For defining service logs to a set of resources within specified compartments, use *flow_logs* or *bucket_logs* attributes.

**Note**: *log_groups*, *service_logs*, *flow_logs*, *bucket_logs*, and *custom_logs* are maps of objects. Each object is defined as a key/value pair. The key must be unique and not be changed once defined. See the [examples](./examples/) folder for sample declarations.

The *default_* attributes are the following:

- **default_compartment_id**: (Optional) The default compartment for all resources managed by this module. It can be overriden by *compartment_id* attribute in each resource. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID. See [External Dependencies](#extdep) section.
- **default_defined_tags**: (Optional) The default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: (Optional) The default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.

The module can also be used to create Logging Analytics log groups and enable Logging Analytics. 

To disable Logging Analytics, navigate to the Logging Analytics service page on the Console and select the "Service Details" section on the bottom left menu. From there, disable Logging Analytics by clicking the red "Terminate" button.

### Defining Log Groups
- **onboard_logging_analytics**: (Optional) Whether your tenancy will enable Logging Analytics. Set to true ONLY if wish to onboard your tenancy to Logging Analytics, set to false if your tenancy has ALREADY enabled Logging Analytics. Check in Console. Default is false.
- **log_groups**: A map of log groups. In OCI, every log must belong to a log group.
  - **compartment_id**: (Optional) The compartment where the log group is created. *default_compartment_id* is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID. See [External Dependencies](#extdep) section.
  - **type**: (Optional) Include this value and set it to "logging_analytics" to create a Logging Analytics log group, otherwise a default log group will be created. 
  - **name**: The log group name.             
  - **description**: (Optional) The log group description. It defaults to log group name if undefined.      
  - **defined_tags**: (Optional) The log group defined tags. *default_defined_tags* is used if undefined.
  - **freeform_tags**: (Optional) The log group freeform tags. *default_freeform_tags* is used if undefined.   

### Defining Service Logs  
- **service_logs**: (Optional) A map of service logs. **Use this when defining service logs for single resources**. Logs are created in the same compartment as the enclosing log group.
  - **name**: The log name.
  - **log_group_id**: The log group. The value should be one of the reference keys defined in *log_groups*.
  - **service**: The resource service name for which the log is being created. Sample valid values: "flowlogs", "objectstorage". Supported services may change over time. See [Services Integrated with the Logging Services and their Categories](#services).
  - **category**: The category name within each service. This is service specific and valid values may change over time. See [Services Integrated with the Logging Services and their Categories](#services).
  - **resource_id**: The resource id to create the log for.
  - **is_enabled**: (Optional) Whether the log is enabled. Default is true.
  - **retention_duration**: (Optional) The log retention duration in 30-day increments. Valida values are 30, 60, 90, 120, 150, 180. Default is 30. 
  - **defined_tags**: (Optional) The log defined tags. *default_defined_tags* is used if undefined.
  - **freeform_tags**: (Optional) The log freeform tags. *default_freeform_tags* is used if undefined.

### Defining Flow Logs
- **flow_logs**: A map of flow logs. **Use this when defining flow logs in bulk within specified compartments**. Logs are created in the same compartment as the enclosing flow log group.
  - **name_prefix**: (Optional) a prefix to flow log names.
  - **log_group_id** The flow log group. The value should be one of the reference keys defined in *log_groups*.
  - **target_resource_type** The target resource type for flow logs. Valid values: "vcn", "subnet", "vnic".
  - **target_compartment_ids** The list of compartments containing the resources of type defined in target_resource_type to create flow logs for. The module searches for all resources of target_resource_type in these compartments. For "vnic" target_resource_type, NLB (Network Load Balancer) private IP VNICs are also included.
  - **is_enabled**: (Optional) Whether the flow logs are enabled. Default is true.
  - **retention_duration**: (Optional) The flow log retention duration in 30-day increments. Valida values are 30, 60, 90, 120, 150, 180. Default is 30. 
  - **defined_tags**: (Optional) The flow log defined tags. *default_defined_tags* is used if undefined.
  - **freeform_tags**: (Optional) The flow log freeform tags. *default_freeform_tags* is used if undefined.

### Defining Bucket Logs  
- **bucket_logs**: A map of bucket logs. **Use this when defining bucket logs in bulk within specified compartments**. Logs are created in the same compartment as the enclosing bucket log group.
  - **name_prefix**: (Optional) a prefix to bucket log names.
  - **log_group_id**: The bucket log group. The value should be one of the reference keys defined in *log_groups*.
  - **target_compartment_ids**: The list of compartments containing the buckets to create logs for. The module seaeches for all buckets in these compartments.
  - **category**: The category of operations to enable the bucket logs for. Valid values: "read" or "write".
  - **is_enabled**: (Optional) Whether the bucket logs are enabled. Default is true.
  - **retention_duration**: (Optional) The bucket log retention duration in 30-day increments. Valida values are 30, 60, 90, 120, 150, 180. Default is 30. 
  - **defined_tags**: (Optional) The bucket log defined tags. *default_defined_tags* is used if undefined.
  - **freeform_tags**: (Optional) The bucket log freeform tags. *default_freeform_tags* is used if undefined.

### Defining Custom Logs  
- **custom_logs**: A map of custom logs. **Use this when defining custom logs for single resources**. Logs are created in the same compartment as the enclosing log group.
  - **compartment_id**: (Optional) The compartment where log is created. *default_compartment_id* is used if undefined. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
  - **name**: The log name.
  - **log_group_id**: The log group. The value should be one of the reference keys defined in *log_groups*.
  - **dynamic_groups**: The list of dynamic groups associated with this configuration
  - **parser_type**: (Optional) The type of fluent parser. Valid values: "NONE", "SYSLOG", "CSV", "TSV", "REGEXP", "MULTILINE", "APACHE_ERROR", "APACHE2", "AUDITD", "JSON", "CRI". Default is "NONE".
  - **path**: Absolute paths for log source files. Wildcards can be used.
  - **is_enabled**: (Optional) Whether the log is enabled. Default is true.
  - **retention_duration**: (Optional) The log retention duration in 30-day increments. Valida values are 30, 60, 90, 120, 150, 180. Default is 30. 
  - **defined_tags**: (Optional) The log defined tags. *default_defined_tags* is used if undefined.
  - **freeform_tags**: (Optional) The log freeform tags. *default_freeform_tags* is used if undefined.

### <a name="services">Services Integrated with the Logging Services and their Categories</a>

As of Oct/2023, these are the OCI services that are integrated with the Logging service. Use this as reference to fill in *service* and *category* attributes when creating logs using the *service_log* attribute.
For any updates, use OCI CLI to execute ```oci logging service list```.

Service | Service Name | Categories 
--------------|-------------|-------------
Analytics Cloud |"oacnativeproduction" | "audit", "diagnostic"
API Gateway | "apigateway" | "access", "execution"
Application Dependency Management | "adm" | "remediationrecipelogs"
Application Performance Monitoring | "apm" | "dropped-data"
Connector Hub | "och" | "runlog"
Container Engine for Kubernetes | "oke-k8s-cp-prod" | "kube-apiserver", "all-service-logs", "cloud-controller-manager", "kube-controller-manager", "kube-scheduler"
Content Delivery Network | "contentdeliverynetwork" | "access", "error"
Data Flow | "dataflow" | "diagnostic"
Data Integration Service | "dataintegration" | "disworkspacelogs"
Data Science | "datascience" | "pipelinerunlog"
DevOps | "devops" | "all"
Email Delivery | "emaildelivery" | "outboundaccepted", "outboundrelayed"
Events Service | "cloudevents" | "ruleexecutionlog"
File Storage | "filestorage" | "nfslogs"
Functions | "functions" | "invoke"
GoldenGate | "goldengate" | "process_logs", "error_logs"
Integration | "integration" | "activitystream"
Load Balancers | "loadbalancer" | "access", "error"
Media Flow | "mediaflow" | "execution"
Network Firewall | "ocinetworkfirewall" | "threatlog", "trafficlog"
Object Storage | "objectstorage" | "read", "write"
Operator Access Control Service | "operatoraccessprod" | "access"
Site-To-Site VPN | "oci_c3_vpn" | "read"
Virtual Cloud Network - Flowlogs | "flowlogs" | "vcn", "subnet", "vnic", "all" (valid for subnets only)
WAA Service | "waa" | "all"
WAF Service | "waf" | "all"

### <a name="extdep">External Dependencies</a>

An optional feature, external dependencies are resources managed elsewhere that resources managed by this module may depend on. The following dependencies are supported:

- **compartments_dependency**: A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the compartment OCID. This mechanism allows for the usage of referring keys (instead of OCIDs) in *default_compartment_id* and *compartment_id* attributes. The module replaces the keys by the OCIDs provided within *compartments_dependency* map. Contents of *compartments_dependency* is typically the output of a [Compartments module](../compartments/) client.

## <a name="related">Related Documentation</a>
- [OCI Logging](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm)
- [Logging in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log)

## <a name="issues">Known Issues</a>
1. Attempting to onboard your tenancy to Logging Analytics more than once will cause errors.
   ```
   `Error: 409-Conflict, Error on-boarding LogAnalytics for tenant idbktv455emw as it is already on-boarded or in the process of getting on-boarded`
   ```
   Avoid this error by first checking in your Oracle Cloud Console if Logging Analytics has been enabled. If it has been enabled, set the `onboard_logging_analytics` variable to `false`.

2. *bucket_logs* and *flow_logs* attributes should not be used if this module is used in conjunction with another module that creates the compartments referenced in *target_compartment_ids* attribute of *bucket_logs* and *flow_logs*. Such an attempt makes Terraform plan to fail with the following error:
    ```
    Error: Invalid for_each argument

      on .terraform/modules/oci_lz_orchestrator.oci_lz_logging/logging/bucket_logs.tf line 38, in data "oci_objectstorage_bucket_summaries" "these" 

      38:   for_each = toset(local.bucket_logs_compartment_ids)

        ├────────────────

        │ local.bucket_logs_compartment_ids is tuple with 3 elements

    The "for_each" set includes values derived from resource attributes that

    cannot be determined until apply, and so Terraform cannot determine the full

    set of keys that will identify the instances of this resource.

    When working with unknown values in for_each, it's better to use a map value

    where the keys are defined statically in your configuration and where only

    the values contain apply-time results.

    Alternatively, you could use the -target planning option to first apply only

    the resources that the for_each value depends on, and then apply a second

    time to fully converge.

    Error: Invalid for_each argument

      on .terraform/modules/oci_lz_orchestrator.oci_lz_logging/logging/flow_logs.tf line 115, in data "oci_identity_compartment" "these" 

    115:   for_each = toset(local.flow_logs_compartment_ids)

        ├────────────────

        │ local.flow_logs_compartment_ids is tuple with 1 element

    The "for_each" set includes values derived from resource attributes that

    cannot be determined until apply, and so Terraform cannot determine the full

    set of keys that will identify the instances of this resource.

    When working with unknown values in for_each, it's better to use a map value

    where the keys are defined statically in your configuration and where only

    the values contain apply-time results.

    Alternatively, you could use the -target planning option to first apply only

    the resources that the for_each value depends on, and then apply a second

    time to fully converge.

    Error: Invalid for_each argument

      on .terraform/modules/oci_lz_orchestrator.oci_lz_logging/logging/flow_logs.tf line 137, in data "oci_core_vcns" "these" 

    137:   for_each = toset(local.flow_logs_compartment_ids)

        ├────────────────

        │ local.flow_logs_compartment_ids is tuple with 1 element

    The "for_each" set includes values derived from resource attributes that

    cannot be determined until apply, and so Terraform cannot determine the full

    set of keys that will identify the instances of this resource.

    When working with unknown values in for_each, it's better to use a map value

    where the keys are defined statically in your configuration and where only

    the values contain apply-time results.

    Alternatively, you could use the -target planning option to first apply only

    the resources that the for_each value depends on, and then apply a second

    time to fully converge. 
    ```
In such scenario, create logs using the *service_logs* attribute instead. 
