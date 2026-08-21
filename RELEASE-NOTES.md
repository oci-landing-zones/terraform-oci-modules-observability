# Unreleased

## Updates
1. [Alarms module](./alarms/)
  - Enhancement: Added 33 new [preconfigured alarm types](./alarms/preconfigured_alarms.tf) for Compute, Autonomous Database, Network, Database Cluster, and Database monitoring. Database alarms apply to cloud databases in general, including Exadata Cloud@Customer, and covering VM clusters as well as Real Application Clusters (RAC).
  - **Compute**: *COMPUTE-HIGH-CPU-ALARM-WARNING*, *COMPUTE-HIGH-CPU-ALARM-CRITICAL*, *COMPUTE-VM-STATUS-ALARM-CRITICAL*, *COMPUTE-MAINTENANCE-ALARM-WARNING*, *COMPUTE-BARE-METAL-HEALTH-ALARM-CRITICAL*, *COMPUTE-HIGH-MEMORY-ALARM-WARNING*, and *COMPUTE-HIGH-MEMORY-ALARM-CRITICAL*.
  - **Autonomous Database**: *ADB-HIGH-CPU-ALARM-WARNING*, *ADB-HIGH-CPU-ALARM-CRITICAL*, *ADB-HIGH-STORAGE-ALARM-WARNING*, *ADB-HIGH-STORAGE-ALARM-CRITICAL*, *ADB-FAILED-LOGINS-ALARM-WARNING*, *ADB-FAILED-LOGINS-ALARM-CRITICAL*, *ADB-MONITORING-AVAILABILITY-ALARM-CRITICAL*, and *ADB-SESSIONS-ALARM-WARNING*.
  - **Network**: *NETWORK-VPN-STATUS-ALARM-CRITICAL*, *NETWORK-FAST-CONNECT-STATUS-ALARM-CRITICAL*, and *NETWORK-VNIC-CONNECTION-TRACKING-ALARM-CRITICAL*.
  - **Database Cluster**: *DATABASE-CLUSTER-HIGH-CPU-ALARM-WARNING*, *DATABASE-CLUSTER-HIGH-CPU-ALARM-CRITICAL*, *DATABASE-CLUSTER-HIGH-MEMORY-ALARM-WARNING*, *DATABASE-CLUSTER-HIGH-MEMORY-ALARM-CRITICAL*, *DATABASE-CLUSTER-HIGH-FILESYSTEM-UTILIZATION-ALARM-WARNING*, *DATABASE-CLUSTER-HIGH-FILESYSTEM-UTILIZATION-ALARM-CRITICAL*, *DATABASE-CLUSTER-HIGH-ASM-DISKGROUP-UTILIZATION-ALARM-WARNING*, *DATABASE-CLUSTER-HIGH-ASM-DISKGROUP-UTILIZATION-ALARM-CRITICAL*, *DATABASE-CLUSTER-HIGH-SWAP-UTILIZATION-ALARM-WARNING*, *DATABASE-CLUSTER-HIGH-SWAP-UTILIZATION-ALARM-CRITICAL*, and *DATABASE-CLUSTER-NODE-STATUS-ALARM-CRITICAL*.
  - **Database**: *DATABASE-HIGH-CPU-ALARM-WARNING*, *DATABASE-HIGH-CPU-ALARM-CRITICAL*, *DATABASE-HIGH-STORAGE-UTILIZATION-ALARM-WARNING*, and *DATABASE-HIGH-STORAGE-UTILIZATION-ALARM-CRITICAL*.
  - Deprecation: The following legacy types are deprecated. Update configurations to use the indicated replacement types:
    - *high-cpu-alarm*: *COMPUTE-HIGH-CPU-ALARM-WARNING* or *COMPUTE-HIGH-CPU-ALARM-CRITICAL*.
    - *instance-status-alarm*: *COMPUTE-VM-STATUS-ALARM-CRITICAL*.
    - *vm-maintenance-alarm*: *COMPUTE-MAINTENANCE-ALARM-WARNING*.
    - *bare-metal-unhealthy-alarm*: *COMPUTE-BARE-METAL-HEALTH-ALARM-CRITICAL*.
    - *high-memory-alarm*: *COMPUTE-HIGH-MEMORY-ALARM-WARNING* or *COMPUTE-HIGH-MEMORY-ALARM-CRITICAL*.
    - *adb-cpu-alarm*: *ADB-HIGH-CPU-ALARM-WARNING* or *ADB-HIGH-CPU-ALARM-CRITICAL*.
    - *adb-storage-alarm*: *ADB-HIGH-STORAGE-ALARM-WARNING* or *ADB-HIGH-STORAGE-ALARM-CRITICAL*.
    - *vpn-status-alarm*: *NETWORK-VPN-STATUS-ALARM-CRITICAL*.
    - *fast-connect-status-alarm*: *NETWORK-FAST-CONNECT-STATUS-ALARM-CRITICAL*.

2. [Events module](./events/)
  - Enhancement: Added the following [preconfigured database events](./events/preconfigured_events.tf):
    - *com.oraclecloud.databaseservice.dbsystem.critical*
    - *com.oraclecloud.databaseservice.database.critical*
    - *com.oraclecloud.databaseservice.dbnode.critical*
    - *com.oraclecloud.databaseservice.autonomous.container.database.critical*
    - *com.oraclecloud.databaseservice.autonomous.cloudautonomousvmcluster.critical*
    - *com.oraclecloud.databaseservice.autonomous.vmcluster.critical*
    - *com.oraclecloud.databaseservice.exadatainfrastructureconnectstatus*
  - Deprecation: The *exainfra* preconfigured event type is deprecated. Update configurations to use *database-infra*, which includes the Exadata infrastructure critical event and the new cloud database infrastructure events.

# February 20, 2026 Release Notes - 0.2.5

## Updates
1. [Service Connectors module](./service-connectors/)
  - Enhancement: Added monitoring as source and target in service connectors.

# October 10, 2025 Release Notes - 0.2.4

## Updates
1. Format the code to adhere to Terraform standards.
2. [Service Connectors module](./service-connectors/)
    - Bug fix: Add *kms_key_id_replica* to allow a kms key for bucket replica in bucket replication.
3. [Events module](./events/)
    - Event *com.oraclecloud.identitycontrolplane.createidpgroupmapping* and *com.oraclecloud.identitycontrolplane.deleteidpgroupmapping* are updated to *com.oraclecloud.identitycontrolplane.addidpgroupmapping* and *com.oraclecloud.identitycontrolplane.removeidpgroupmapping* in IAM pre-configured events.
4. [Logging module](./logging/)
    - Add *defined_tags* and *freeform_tags* in logging.

   
# April 28, 2025 Release Notes - 0.2.3

## Updates
1. [Streams module](./streams/)
    - Lifecycle argument *create_before_destroy = true* removed from *oci_streaming_stream_pool* resource.

# April 01, 2025 Release Notes - 0.2.2

## Updates
1. [Events module](./events/)
    - Event *com.oraclecloud.identitysignon.interactivelogin* added to IAM pre-configured events.

# December 18, 2024 Release Notes - 0.2.1

## Updates
1. [Logging module](./logging/)
    - Bug fix: *compartment_id* attribute added to *custom_logs* attribute and respective logic added to *oci_logging_unified_agent_configuration* resource for taking a literal OCID or a reference to an OCID.

# December 09, 2024 Release Notes - 0.2.0

## Updates
1. [Service Connectors module](./service-connectors/)
    - Bug fix: syntax fix in IAM policy when Service Connector target is an OCI stream.

# September 20, 2024 Release Notes - 0.1.9

## Updates
1. [Logging module](./logging/)
    - Per CIS framework recommendation 8.10, the module now, by default, enforces a retention duration of at least 90 days for all logs. This can be disabled by setting *enable_cis_checks* attribute to false.
    - Log groups can now be injected via the external dependency mechanism. Attribute *log_group_id*, in addition to being a reference key defined in *log_groups* attribute, can now also be a log group OCID or a reference key defined in *log_groups_dependency* variable. 
    - Bug fix: log names can now be created for network resources (like subnets and VCNs) with spaces in their names.

# August 27, 2024 Release Notes - 0.1.8

## Updates
1. All modules now require Terraform binary equal or greater than 1.3.0.
2. *cislz-terraform-module* tag renamed to *ocilz-terraform-module*.

# July 24, 2024 Release Notes - 0.1.7

## Updates
1. Aligned [README.md](./README.md) structure to Oracle's GitHub organizations requirements.
2. [Service Connectors module](./service-connectors/)
    - Target buckets can now be archived, replicated to another region and configured with retention rules.

# May 22, 2024 Release Notes - 0.1.6

## Updates
1. [Notifications module](./notifications/)
    - Support for announcement subscriptions via the newly added *announcement_subscriptions* attribute.

2. [Service Connector Hub module](./service-connectors/)
    - Retention rules support for bucket targets.
    - Cursor support for streaming targets.


# April 05, 2024 Release Notes - 0.1.5

## Updates
### Logging Module
1. Support for Logging Analytics log groups added.


# February 28, 2024 Release Notes - 0.1.4

## Updates
### Events Module
1. Networking events updated:
    - Delete event for Local Peering Gateway renamed to *com.oraclecloud.virtualnetwork.deletelocalpeeringgateway.end*.
    - Event *com.oraclecloud.servicegateway.deleteservicegateway.begin* removed.
2. The reserved key "TENANCY-ROOT" has been introduced. It is used for referring to the root compartment OCID and can be assigned to *default_compartment_id* and *compartment_id* and *metric_compartment_id* attributes.

### Alarms Module
1. The reserved key "TENANCY-ROOT" has been introduced. It is used for referring to the root compartment OCID and can be assigned to *default_compartment_id* and *compartment_id* attributes.

# January 10, 2024 Release Notes - 0.1.3

## Added
1. Logging module, supporting service logs and custom logs, with the additional ability for bulk provisioning bucket logs and flow logs.

# September 28, 2023 Release Notes - 0.1.2

## Updates
1. [Notification Frequency for Critical Alarms](#0-1-2-alarms)

### <a name="0-1-2-alarms">Notification Frequency for Critical Alarms</a>
Default notification frequency for critical alarms set to every 4 hours ("PT4H").

# August 04, 2023 Release Notes - 0.1.1

## Updates
1. [External Dependencies](#0-1-1-ext-dep)

### <a name="0-1-1-ext-dep">External Dependencies</a>
For improved automation, the modules now support external dependencies, where resources managed elsewhere can be provided in a JSON-formated file. The modules replace references given in the input variables by the actual resource OCIDs in the provided JSON-formatted dependency files.

# April 28, 2023 Release Notes - 0.1.0

## Added
1. [Initial Release](#0-1-0-initial)

### <a name="0-1-0-initial">Initial Release</a>
Modules for alarms, events, notifications, service connectors and streams.
