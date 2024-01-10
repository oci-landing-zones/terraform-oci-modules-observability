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
