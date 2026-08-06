# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  preconfigured_alarms = {
    high-cpu-alarm = {
      namespace                           = "oci_computeagent"
      query                               = "CpuUtilization[1m].mean() > 80"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    instance-status-alarm = {
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "instance_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    vm-maintenance-alarm = {
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "maintenance_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    bare-metal-unhealthy-alarm = {
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "health_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    high-memory-alarm = {
      namespace                           = "oci_computeagent"
      query                               = "MemoryUtilization[1m].mean() > 80"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    adb-cpu-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "CpuUtilization[5m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    adb-storage-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    dbm-failed-logins-critical-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 30"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    dbm-failed-logins-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 20"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    dbm-monitoring-stopped-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "DatabaseAvailability[10m].absent()"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT1M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    dbm-sessions-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "Sessions[15m].mean() > 30"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    dbm-storage-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    vpn-status-alarm = {
      namespace                           = "oci_vpn"
      query                               = "TunnelState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    fast-connect-status-alarm = {
      namespace                           = "oci_fastconnect"
      query                               = "ConnectionState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
  }


}
