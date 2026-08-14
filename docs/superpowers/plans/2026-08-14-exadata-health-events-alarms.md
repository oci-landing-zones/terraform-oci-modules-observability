# Exadata Health Events and Alarms Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add backward-compatible ExaCS and ExaC@C critical-event coverage and eight reusable Exadata health alarms to the observability module.

**Architecture:** Extend the existing `database` and `exainfra` event categories so current consumers receive the new signals automatically. Add deployment-neutral alarms backed by the shared `oci_database_cluster` and `oci_database` namespaces, with query intervals aligned to Oracle's documented metric emission frequencies.

**Tech Stack:** Terraform HCL, OCI Terraform provider, Terraform native tests.

## Global Constraints

- Preserve the existing `database` and `exainfra` category names and all existing alarm keys.
- Include critical conditions and availability only; exclude warning, informational, lifecycle, and maintenance events.
- Use `> 80` for every utilization alarm.
- Use `CRITICAL`, `PRETTY_JSON`, `PT5M`, and `PT4H` for every new alarm.
- Do not add module inputs or product-specific ExaCS and ExaC@C alarm duplicates.
- Preserve the unrelated untracked `logging/examples/issue29/` directory.

---

### Task 1: Extend the Exadata event catalog

**Files:**
- Create: `events/tests/preconfigured_exadata_events.tftest.hcl`
- Modify: `events/preconfigured_events.tf`

**Interfaces:**
- Consumes: `local.preconfigured_events.database.conditions` and `local.preconfigured_events.exainfra.conditions`.
- Produces: the existing category keys with exact ExaCS and ExaC@C critical and availability event membership.

- [ ] **Step 1: Write the failing event catalog test**

```hcl
mock_provider "oci" {}

variables {
  events_configuration = {
    default_compartment_id = "ocid1.compartment.oc1..test"
    event_rules            = {}
  }
}

run "exadata_event_categories_cover_critical_health_and_availability" {
  command = plan

  assert {
    condition = toset(local.preconfigured_events.database.conditions) == toset([
      "com.oraclecloud.databaseservice.autonomous.database.critical",
      "com.oraclecloud.databaseservice.dbsystem.critical",
      "com.oraclecloud.databaseservice.database.critical",
      "com.oraclecloud.databaseservice.dbnode.critical",
      "com.oraclecloud.databaseservice.autonomous.container.database.critical"
    ])
    error_message = "The database category must contain the complete approved Exadata database critical-event set."
  }

  assert {
    condition = toset(local.preconfigured_events.exainfra.conditions) == toset([
      "com.oraclecloud.databaseservice.exadatainfrastructure.critical",
      "com.oraclecloud.databaseservice.autonomous.cloudautonomousvmcluster.critical",
      "com.oraclecloud.databaseservice.autonomous.vmcluster.critical",
      "com.oraclecloud.databaseservice.exadatainfrastructureconnectstatus"
    ])
    error_message = "The exainfra category must contain the complete approved ExaCS and ExaC@C critical and availability event set."
  }
}
```

- [ ] **Step 2: Initialize and run the test to verify it fails**

Run:

```powershell
terraform1_15_1 -chdir=events init -backend=false
terraform1_15_1 -chdir=events test -filter=tests\preconfigured_exadata_events.tftest.hcl -no-color
```

Expected: the run fails because both category sets lack the approved Exadata events.

- [ ] **Step 3: Add the five event types**

In `events/preconfigured_events.tf`, append the three approved database event types to `database.conditions` and the two approved infrastructure event types to `exainfra.conditions`, preserving all existing entries.

- [ ] **Step 4: Run the focused event test**

Run: `terraform1_15_1 -chdir=events test -filter=tests\preconfigured_exadata_events.tftest.hcl -no-color`

Expected: `1 passed, 0 failed`.

- [ ] **Step 5: Commit the event catalog slice**

```powershell
git add events/preconfigured_events.tf events/tests/preconfigured_exadata_events.tftest.hcl
git commit -m "feat(events): add Exadata critical health events"
```

### Task 2: Add shared Exadata health alarms

**Files:**
- Create: `alarms/tests/preconfigured_exadata_alarms.tftest.hcl`
- Modify: `alarms/preconfigured_alarms.tf`
- Modify: `alarms/README.md`

**Interfaces:**
- Consumes: `local.preconfigured_alarms` and the existing `preconfigured_alarm_type` selection mechanism.
- Produces: eight new alarm keys with exact namespaces, queries, and shared alarm defaults.

- [ ] **Step 1: Write the failing alarm catalog test**

```hcl
mock_provider "oci" {}

variables {
  alarms_configuration = {
    default_compartment_id = "ocid1.compartment.oc1..test"
    alarms                = {}
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
    error_message = "Every approved Exadata alarm must use its documented namespace and metric-aligned query interval."
  }

  assert {
    condition = alltrue([
      for key in [
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
      )
    ])
    error_message = "Every approved Exadata alarm must use the shared critical alarm defaults."
  }
}
```

- [ ] **Step 2: Initialize and run the test to verify it fails**

Run:

```powershell
terraform1_15_1 -chdir=alarms init -backend=false
terraform1_15_1 -chdir=alarms test -filter=tests\preconfigured_exadata_alarms.tftest.hcl -no-color
```

Expected: the run fails because all eight alarm keys are absent.

- [ ] **Step 3: Add the eight alarm definitions**

In `alarms/preconfigured_alarms.tf`, add the eight exact key, namespace, and query combinations asserted above. Set every definition to:

```hcl
severity                            = "CRITICAL"
message_format                      = "PRETTY_JSON"
pending_duration                    = "PT5M"
repeat_notification_critical_alarms = "PT4H"
```

- [ ] **Step 4: Update the supported alarm-type documentation**

Extend the supported-value list in `alarms/README.md` with all eight new alarm keys. Keep the existing list and link to `preconfigured_alarms.tf` intact.

- [ ] **Step 5: Run the focused alarm test**

Run: `terraform1_15_1 -chdir=alarms test -filter=tests\preconfigured_exadata_alarms.tftest.hcl -no-color`

Expected: `1 passed, 0 failed`.

- [ ] **Step 6: Commit the alarm catalog slice**

```powershell
git add alarms/preconfigured_alarms.tf alarms/tests/preconfigured_exadata_alarms.tftest.hcl alarms/README.md
git commit -m "feat(alarms): add shared Exadata health alarms"
```

### Task 3: Verify both module catalogs

**Files:**
- Test: `events/tests/preconfigured_exadata_events.tftest.hcl`
- Test: `alarms/tests/preconfigured_exadata_alarms.tftest.hcl`

**Interfaces:**
- Consumes: the completed Events and Alarms modules.
- Produces: formatting, test, validation, and patch-hygiene evidence for the branch.

- [ ] **Step 1: Format the changed Terraform files**

Run:

```powershell
terraform1_15_1 fmt events/preconfigured_events.tf events/tests/preconfigured_exadata_events.tftest.hcl alarms/preconfigured_alarms.tf alarms/tests/preconfigured_exadata_alarms.tftest.hcl
```

- [ ] **Step 2: Run both complete module test suites**

```powershell
terraform1_15_1 -chdir=events test -no-color
terraform1_15_1 -chdir=alarms test -no-color
```

- [ ] **Step 3: Validate both modules**

```powershell
terraform1_15_1 -chdir=events validate -no-color
terraform1_15_1 -chdir=alarms validate -no-color
```

- [ ] **Step 4: Check patch hygiene and scope**

```powershell
git diff --check HEAD~2..HEAD
git status --short
```

Expected: validation succeeds, tests report zero failures, diff check is clean, and `logging/examples/issue29/` remains the only unrelated untracked path.
