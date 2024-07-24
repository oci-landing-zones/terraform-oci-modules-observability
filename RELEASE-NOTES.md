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
