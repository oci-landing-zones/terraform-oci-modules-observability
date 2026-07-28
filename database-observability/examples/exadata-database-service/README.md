# Exadata Database Service example

This example enables Database Management and Operations Insights for an Exadata
Database Service CDB/PDB pair. It follows the One-OE Landing Zone reference-key
style used by the ExaDB-D workload extension.

The CDB is always enabled before the PDB. Disabling is intentionally staged:

1. Change `operation_stage` to `DISABLE_TARGETS`, review and apply the plan.
   Operations Insights is removed before DBM target disablement.
2. Confirm collection has stopped and create a new plan with
   `operation_stage` set to `DISABLE_CDB`.
3. The second plan reads each PDB through its `managed_database_id` and fails
   unless its Database Management feature is already disabled.

Copy `input.auto.tfvars.json.template` to an ignored
`input.auto.tfvars.json`, populate its dependency maps from the Landing Zone
outputs, authenticate through the execution environment, and review a saved
plan before apply.
