mock_provider "oci" {}

variables {
  alarms_configuration = {
    default_compartment_id = "ocid1.compartment.oc1..test"
    alarms                 = {}
  }
}

run "exadata_alarm_catalog_uses_documented_metric_intervals" {
  command = plan

  assert {
    condition = alltrue([
      try(local.preconfigured_alarms["exadata-vm-cluster-high-cpu-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-high-cpu-alarm"].query == "CpuUtilization[1m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-vm-cluster-high-memory-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-high-memory-alarm"].query == "MemoryUtilization[1m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-vm-cluster-high-filesystem-utilization-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-high-filesystem-utilization-alarm"].query == "FilesystemUtilization[1m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-vm-cluster-high-asm-diskgroup-utilization-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-high-asm-diskgroup-utilization-alarm"].query == "ASMDiskgroupUtilization[10m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-vm-cluster-high-swap-utilization-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-high-swap-utilization-alarm"].query == "SwapUtilization[1m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-vm-cluster-node-status-alarm"].namespace == "oci_database_cluster" && local.preconfigured_alarms["exadata-vm-cluster-node-status-alarm"].query == "NodeStatus[1m].mean() == 0", false),
      try(local.preconfigured_alarms["exadata-database-high-cpu-alarm"].namespace == "oci_database" && local.preconfigured_alarms["exadata-database-high-cpu-alarm"].query == "CpuUtilization[5m].mean() > 80", false),
      try(local.preconfigured_alarms["exadata-database-high-storage-utilization-alarm"].namespace == "oci_database" && local.preconfigured_alarms["exadata-database-high-storage-utilization-alarm"].query == "StorageUtilization[1h].mean() > 80", false)
    ])
    error_message = "The Exadata alarm catalog must use the approved namespaces, metrics, intervals, and thresholds."
  }

  assert {
    condition = alltrue([for key in [
      "exadata-vm-cluster-high-cpu-alarm",
      "exadata-vm-cluster-high-memory-alarm",
      "exadata-vm-cluster-high-filesystem-utilization-alarm",
      "exadata-vm-cluster-high-asm-diskgroup-utilization-alarm",
      "exadata-vm-cluster-high-swap-utilization-alarm",
      "exadata-vm-cluster-node-status-alarm",
      "exadata-database-high-cpu-alarm",
      "exadata-database-high-storage-utilization-alarm"
      ] : try(
      local.preconfigured_alarms[key].severity == "CRITICAL" &&
      local.preconfigured_alarms[key].message_format == "PRETTY_JSON" &&
      local.preconfigured_alarms[key].pending_duration == "PT5M" &&
      local.preconfigured_alarms[key].repeat_notification_critical_alarms == "PT4H",
      false
    )])
    error_message = "Every Exadata alarm must use the common critical-alarm defaults."
  }
}
