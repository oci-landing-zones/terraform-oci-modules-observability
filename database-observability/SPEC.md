# OCI Landing Zone Database Observability Module Specification

## Requirements

| Name | Version |
| --- | --- |
| Terraform | `>= 1.5.0, < 2.0.0` |
| OCI provider | `>= 6.0.0, < 9.0.0` |

## Providers

| Name | Source |
| --- | --- |
| OCI | `oracle/oci` |
| Terraform built-in | `terraform.io/builtin/terraform` |

## Managed resources

| Name | Type | Purpose |
| --- | --- | --- |
| `oci_database_management_db_management_private_endpoint.these` | resource | Optional DBM private endpoints |
| `oci_opsi_operations_insights_private_endpoint.these` | resource | Optional OPSI private endpoints |
| `oci_database_management_database_dbm_features_management.cdb` | resource | CDB Database Management lifecycle |
| `oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management.pdb` | resource | PDB Database Management lifecycle |
| `oci_database_management_database_dbm_features_management.non_cdb` | resource | Non-CDB Database Management lifecycle |
| `oci_opsi_database_insight.these` | resource | Operations Insights enablement |
| `terraform_data.module_contract` | resource | Fail-closed module invariants |
| `terraform_data.pdb_disable_observation` | resource | CDB disable guard |

## Data sources

| Name | Purpose |
| --- | --- |
| `oci_database_management_managed_database.pdb_disable_observation` | Reads current PDB Database Management feature status during `DISABLE_CDB` planning |

## Inputs

| Name | Type | Default | Required | Description |
| --- | --- | --- | :---: | --- |
| `database_observability_configuration` | object | n/a | yes | Module configuration described below |
| `tenancy_ocid` | string | `null` | no | Required only for `TENANCY-ROOT` |
| `compartments_dependency` | `map(object({id=string}))` | `{}` | no | Landing Zone compartment outputs |
| `vcns_dependency` | `map(object({id=string}))` | `{}` | no | Landing Zone VCN outputs |
| `subnets_dependency` | `map(object({id=string}))` | `{}` | no | Landing Zone subnet outputs |
| `network_security_groups_dependency` | `map(object({id=string}))` | `{}` | no | Landing Zone NSG outputs |
| `databases_dependency` | `map(object({id=string}))` | `{}` | no | Cloud database and PDB outputs |
| `managed_databases_dependency` | `map(object({id=string}))` | `{}` | no | DBM managed-database identities used for disable verification |
| `vault_secrets_dependency` | `map(object({id=string}))` | `{}` | no | Vault secret outputs |
| `dbm_private_endpoints_dependency` | `map(object({id=string}))` | `{}` | no | Existing DBM private endpoints |
| `opsi_private_endpoints_dependency` | `map(object({id=string}))` | `{}` | no | Existing OPSI private endpoints |
| `enable_output` | bool | `true` | no | Enables module outputs |
| `module_name` | string | `"database-observability"` | no | Landing Zone module tag |

### `database_observability_configuration`

| Attribute | Type | Default | Required | Description |
| --- | --- | --- | :---: | --- |
| `default_compartment_id` | string | n/a | yes | Literal OCID, compartment dependency key, or `TENANCY-ROOT` |
| `default_defined_tags` | `map(string)` | `{}` | no | Default defined tags |
| `default_freeform_tags` | `map(string)` | `{}` | no | Default freeform tags |
| `lifecycle_id` | string | n/a | yes | Stable ownership identifier |
| `operation_stage` | string | `"ENABLE"` | no | `ENABLE`, `DISABLE_TARGETS`, or `DISABLE_CDB` |
| `dbm_private_endpoints` | map(object) | `{}` | no | DBM private endpoints managed by this module |
| `opsi_private_endpoints` | map(object) | `{}` | no | OPSI private endpoints managed by this module |
| `databases` | map(object) | n/a | yes | Reviewed database targets keyed by stable logical name |

### Database target object

| Attribute | Type | Default | Required | Description |
| --- | --- | --- | :---: | --- |
| `compartment_id` | string | default compartment | no | Literal OCID or compartment key |
| `database_id` | string | n/a | yes | Literal cloud database/PDB OCID or database key |
| `database_type` | string | n/a | yes | `CDB`, `PDB`, or `NON_CDB` |
| `parent_database_key` | string | `null` | PDB only | Key of an `ADVANCED` CDB in the same map |
| `managed_database_id` | string | `null` | disable only | Literal managed-database OCID or dependency key |
| `dbm_private_endpoint_id` | string | n/a | yes | Created endpoint key, dependency key, or literal OCID |
| `opsi_private_endpoint_id` | string | `null` | OPSI only | Created endpoint key, dependency key, or literal OCID |
| `enable_operations_insights` | bool | `false` | no | Creates a Database Insight |
| `management_type` | string | `"ADVANCED"` | no | `BASIC` or `ADVANCED` |
| `service_name` | string | n/a | yes | Reviewed listener service name |
| `password_secret_id` | string | n/a | yes | Vault secret dependency key or literal OCID |
| `ssl_secret_id` | string | `null` | TCPS only | Vault secret for SSL keystore/truststore details |
| `monitoring_user` | string | `"DBSNMP"` | no | Database monitoring user |
| `role` | string | `"NORMAL"` | no | Supported OCI database connection role |
| `protocol` | string | `"TCP"` | no | `TCP` or `TCPS` |
| `port` | number | `1521` | no | Listener port from 1 through 65535 |
| `defined_tags` | `map(string)` | `{}` | no | Per-target defined tags |
| `freeform_tags` | `map(string)` | `{}` | no | Per-target freeform tags |

The machine-readable equivalent is
[`schemas/database-observability.schema.json`](./schemas/database-observability.schema.json).

## Outputs

| Name | Description |
| --- | --- |
| `dbm_private_endpoints` | Created DBM private endpoint identifiers and placement |
| `opsi_private_endpoints` | Created OPSI private endpoint identifiers and placement |
| `database_management` | DBM action-resource IDs by stable target key |
| `database_insights` | Operations Insights IDs by stable target key |
| `operation_receipt` | Non-secret stage metadata; never an authorization token |

## Invariants

- A configuration contains at least one reviewed target.
- A PDB references an `ADVANCED` CDB in the same target map.
- Plaintext passwords and private keys are not module inputs.
- PDBs use the provider's PDB-specific DBM resource.
- CDB disablement cannot occur in the first disable stage.
- `DISABLE_CDB` requires current provider-backed PDB observations.
- Reused dependencies are not created or deleted by this module.
- Every production apply uses the unchanged, reviewed plan produced for the
  selected execution context.
