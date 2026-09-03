# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  preconfigured_alarms = {
    # Compute Alarms
    high-cpu-alarm = { # deprecated, use COMPUTE-HIGH-CPU-ALARM-WARNING or COMPUTE-HIGH-CPU-ALARM-CRITICAL
      namespace                           = "oci_computeagent"
      query                               = "CpuUtilization[1m].mean() > 80"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    COMPUTE-HIGH-CPU-ALARM-WARNING = {
      namespace                           = "oci_computeagent"
      query                               = "CpuUtilization[1m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    COMPUTE-HIGH-CPU-ALARM-CRITICAL = {
      namespace                           = "oci_computeagent"
      query                               = "CpuUtilization[1m].mean() > 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    instance-status-alarm = { # deprecated, use COMPUTE-VM-STATUS-ALARM-CRITICAL
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "instance_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    COMPUTE-VM-STATUS-ALARM-CRITICAL = { # Only for VM instances.
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "instance_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    vm-maintenance-alarm = { # deprecated, use COMPUTE-MAINTENANCE-ALARM-WARNING
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "maintenance_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    COMPUTE-MAINTENANCE-ALARM-WARNING = { # To both VMs and bare metal instances.
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "maintenance_status[1m].count() == 1"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    bare-metal-unhealthy-alarm = { # deprecated, use COMPUTE-BARE-METAL-HEALTH-ALARM-CRITICAL
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "health_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    COMPUTE-BARE-METAL-HEALTH-ALARM-CRITICAL = { # Only for bare metal instances.
      namespace                           = "oci_compute_infrastructure_health"
      query                               = "health_status[1m].count() == 1"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    high-memory-alarm = { # deprecated, use COMPUTE-HIGH-MEMORY-ALARM-WARNING or COMPUTE-HIGH-MEMORY-ALARM-CRITICAL
      namespace                           = "oci_computeagent"
      query                               = "MemoryUtilization[1m].mean() > 80"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    COMPUTE-HIGH-MEMORY-ALARM-WARNING = {
      namespace                           = "oci_computeagent"
      query                               = "MemoryUtilization[1m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    COMPUTE-HIGH-MEMORY-ALARM-CRITICAL = {
      namespace                           = "oci_computeagent"
      query                               = "MemoryUtilization[1m].mean() > 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }

    # Autonomous Database Alarms
    adb-cpu-alarm = { # deprecated, use ADB-HIGH-CPU-ALARM-WARNING or ADB-HIGH-CPU-ALARM-CRITICAL
      namespace                           = "oci_autonomous_database"
      query                               = "CpuUtilization[5m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-HIGH-CPU-ALARM-WARNING = {
      namespace                           = "oci_autonomous_database"
      query                               = "CpuUtilization[5m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-HIGH-CPU-ALARM-CRITICAL = {
      namespace                           = "oci_autonomous_database"
      query                               = "CpuUtilization[5m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    adb-storage-alarm = { # deprecated, use ADB-HIGH-STORAGE-ALARM-WARNING or ADB-HIGH-STORAGE-ALARM-CRITICAL
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    adb-failed-logins-critical-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 30"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    adb-failed-logins-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 20"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    adb-monitoring-stopped-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "DatabaseAvailability[10m].absent()"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT1M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    adb-sessions-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "Sessions[15m].mean() > 30"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    adb-storage-warning-alarm = {
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-HIGH-STORAGE-ALARM-WARNING = {
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-HIGH-STORAGE-ALARM-CRITICAL = {
      namespace                           = "oci_autonomous_database"
      query                               = "StorageUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }

    }
    ADB-FAILED-LOGINS-ALARM-WARNING = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 20"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-FAILED-LOGINS-ALARM-CRITICAL = {
      namespace                           = "oci_autonomous_database"
      query                               = "FailedLogons[5m].mean() > 30"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-MONITORING-AVAILABILITY-ALARM-CRITICAL = {
      namespace                           = "oci_autonomous_database"
      query                               = "DatabaseAvailability[10m].absent()"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT1M"
      repeat_notification_critical_alarms = "PT4H"
      freeform_tags                       = { provider = "DBM" }
    }
    ADB-SESSIONS-ALARM-WARNING = {
      namespace                           = "oci_autonomous_database"
      query                               = "Sessions[15m].mean() > 30"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
      freeform_tags                       = { provider = "DBM" }
    }
    # Network Alarms
    vpn-status-alarm = { # deprecated, use NETWORK-VPN-STATUS-ALARM-CRITICAL
      namespace                           = "oci_vpn"
      query                               = "TunnelState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    NETWORK-VPN-STATUS-ALARM-CRITICAL = {
      namespace                           = "oci_network"
      query                               = "TunnelState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    fast-connect-status-alarm = { # deprecated, use NETWORK-FAST-CONNECT-STATUS-ALARM-CRITICAL
      namespace                           = "oci_fastconnect"
      query                               = "ConnectionState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    NETWORK-FAST-CONNECT-STATUS-ALARM-CRITICAL = {
      namespace                           = "oci_fastconnect"
      query                               = "ConnectionState[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    NETWORK-VNIC-CONNECTION-TRACKING-ALARM-CRITICAL = {
      namespace                           = "oci_vcn"
      query                               = "VnicConntrackUtilPercent[5m].groupBy(resourceId).max() >= 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"  
    }
    # Database Alarms - apply to cloud databases in general, including Exadata Cloud@Customer.
    DATABASE-CLUSTER-HIGH-CPU-ALARM-WARNING = {
      namespace                           = "oci_database_cluster"
      query                               = "CpuUtilization[5m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-CLUSTER-HIGH-CPU-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "CpuUtilization[5m].mean() > 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-CLUSTER-HIGH-MEMORY-ALARM-WARNING = {
      namespace                           = "oci_database_cluster"
      query                               = "MemoryUtilization[5m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-CLUSTER-HIGH-MEMORY-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "MemoryUtilization[5m].mean() > 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-CLUSTER-HIGH-FILESYSTEM-UTILIZATION-ALARM-WARNING = {
      namespace                           = "oci_database_cluster"
      query                               = "FilesystemUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-CLUSTER-HIGH-FILESYSTEM-UTILIZATION-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "FilesystemUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-CLUSTER-HIGH-ASM-DISKGROUP-UTILIZATION-ALARM-WARNING = {
      namespace                           = "oci_database_cluster"
      query                               = "ASMDiskgroupUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-CLUSTER-HIGH-ASM-DISKGROUP-UTILIZATION-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "ASMDiskgroupUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-CLUSTER-HIGH-SWAP-UTILIZATION-ALARM-WARNING = {
      namespace                           = "oci_database_cluster"
      query                               = "SwapUtilization[5m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-CLUSTER-HIGH-SWAP-UTILIZATION-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "SwapUtilization[5m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-CLUSTER-NODE-STATUS-ALARM-CRITICAL = {
      namespace                           = "oci_database_cluster"
      query                               = "NodeStatus[1m].mean() == 0"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-HIGH-CPU-ALARM-WARNING = {
      namespace                           = "oci_database"
      query                               = "CpuUtilization[5m].mean() > 80"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-HIGH-CPU-ALARM-CRITICAL = {
      namespace                           = "oci_database"
      query                               = "CpuUtilization[5m].mean() > 90"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
    DATABASE-HIGH-STORAGE-UTILIZATION-ALARM-WARNING = {
      namespace                           = "oci_database"
      query                               = "StorageUtilization[30m].mean() > 75"
      severity                            = "WARNING"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = null
    }
    DATABASE-HIGH-STORAGE-UTILIZATION-ALARM-CRITICAL = {
      namespace                           = "oci_database"
      query                               = "StorageUtilization[30m].mean() > 85"
      severity                            = "CRITICAL"
      message_format                      = "PRETTY_JSON"
      pending_duration                    = "PT5M"
      repeat_notification_critical_alarms = "PT4H"
    }
  }


}
