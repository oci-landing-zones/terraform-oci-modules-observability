# Exadata Health Events and Alarms Design

## Goal

Extend the observability module's preconfigured catalogs with health and availability coverage shared by Exadata Database Service on Dedicated Infrastructure (ExaCS/ExaDB-D) and Exadata Database Service on Cloud@Customer (ExaC@C), while preserving existing consumer interfaces.

## Scope

The change extends the existing `database` and `exainfra` event categories and adds reusable Exadata alarm types. It does not add product-specific event categories, lifecycle events, scheduled-maintenance events, warning events, informational events, or new module inputs.

## Event Catalog

Add these critical database signals to the existing `database` category:

- `com.oraclecloud.databaseservice.database.critical`
- `com.oraclecloud.databaseservice.dbnode.critical`
- `com.oraclecloud.databaseservice.autonomous.container.database.critical`

Add these ExaC@C infrastructure signals to the existing `exainfra` category:

- `com.oraclecloud.databaseservice.autonomous.vmcluster.critical`
- `com.oraclecloud.databaseservice.exadatainfrastructureconnectstatus`

Retain the existing Autonomous Database, DB system, ExaCS infrastructure, and public-cloud autonomous VM-cluster critical event types. Connectivity status is included because it is the ExaC@C infrastructure availability signal; lifecycle and maintenance events remain available to callers through `supplied_events`.

## Alarm Catalog

Add eight deployment-neutral preconfigured alarm types:

| Alarm type | Namespace | Query |
| --- | --- | --- |
| `exadata-vm-cluster-high-cpu-alarm` | `oci_database_cluster` | `CpuUtilization[1m].mean() > 80` |
| `exadata-vm-cluster-high-memory-alarm` | `oci_database_cluster` | `MemoryUtilization[1m].mean() > 80` |
| `exadata-vm-cluster-high-filesystem-utilization-alarm` | `oci_database_cluster` | `FilesystemUtilization[1m].mean() > 80` |
| `exadata-vm-cluster-high-asm-diskgroup-utilization-alarm` | `oci_database_cluster` | `ASMDiskgroupUtilization[10m].mean() > 80` |
| `exadata-vm-cluster-high-swap-utilization-alarm` | `oci_database_cluster` | `SwapUtilization[1m].mean() > 80` |
| `exadata-vm-cluster-node-status-alarm` | `oci_database_cluster` | `NodeStatus[1m].mean() == 0` |
| `exadata-database-high-cpu-alarm` | `oci_database` | `CpuUtilization[5m].mean() > 80` |
| `exadata-database-high-storage-utilization-alarm` | `oci_database` | `StorageUtilization[1h].mean() > 80` |

The query intervals match the documented emission frequency of each metric, following OCI Monitoring guidance that alarm intervals must be equal to or longer than metric emission frequency. Every alarm uses the module's existing defaults: `CRITICAL` severity, `PRETTY_JSON` messages, a `PT5M` pending duration, and `PT4H` repeated notifications.

`LoadAverage` is excluded because a portable threshold cannot be selected across differently sized VM clusters. `OcpusAllocated` is excluded because it reports capacity rather than an unhealthy condition.

## Compatibility and Documentation

Existing category names and alarm types remain unchanged. Core Landing Zone can receive the additional events through its existing `database` and `exainfra` category selections. The alarms README supported-value list will include the eight new alarm type names.

## Verification

Terraform contract tests will assert the exact new event membership and alarm namespace/query/default settings. Verification will include formatting, focused tests for both module directories, `terraform validate` in the Events and Alarms modules, and `git diff --check`.

## Authoritative References

- [Exadata Database Service on Dedicated Infrastructure events](https://docs.oracle.com/en/engineered-systems/exadata-cloud-service/ecscm/ecs-events.html)
- [Exadata Database Service on Cloud@Customer events](https://docs.oracle.com/en-us/iaas/exadata/doc/ecc-customer-events.html)
- [Autonomous Exadata events](https://docs.oracle.com/en/cloud/paas/autonomous-database/arfad/)
- [Exadata Database Service on Dedicated Infrastructure metrics](https://docs.oracle.com/en-us/iaas/exadatacloud/doc/metrics-for-exadata-database-service-on-dedicated-infrastructure-in-the-monitoring-service.html)
- [OCI alarm best practices](https://docs.oracle.com/en-us/iaas/Content/Monitoring/Concepts/alarmsbestpractices.htm)
