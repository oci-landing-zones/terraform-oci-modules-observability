# Migration to the Landing Zone database-observability module

This module changes both the public input contract and several Terraform
resource addresses from `terraform/modules/dbm-opsi-enablement`. Treat the
migration as a production state migration, not a normal module-source update.

## Before migration

1. Pin the currently deployed source and OCI provider.
2. Record the current resource addresses with a metadata-only state listing.
3. Back up the encrypted remote state through the state owner's approved
   recovery process.
4. Prove the migration in a non-production or canary compartment.
5. Populate the Landing Zone configuration object with the same target keys,
   database identities, endpoint identities, and Vault secret references.

## Address mapping

The common address changes are:

| Previous module resource | New module resource |
| --- | --- |
| `oci_database_management_database_dbm_features_management.dbm_cdb` | `oci_database_management_database_dbm_features_management.cdb` |
| `oci_database_management_database_dbm_features_management.dbm_standalone` | `oci_database_management_database_dbm_features_management.non_cdb` |
| `oci_opsi_database_insight.insight` | `oci_opsi_database_insight.these` |

Use reviewed `moved` blocks in the calling root when the source and destination
resource schemas are identical. Retain those blocks for supported upgrade
paths.

PDBs require special handling. The earlier module addressed PDBs through
`oci_database_management_database_dbm_features_management`; this module uses
the provider's PDB-specific
`oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management`.
Do not assume Terraform can move state between those resource types. Use a
reviewed declarative import into the new PDB address, remove the old address
only through the approved state-migration process, and require a refreshed plan
with no unintended disable, replacement, or enable action.

## Acceptance

The migration is accepted only when:

- every remote object has exactly one Terraform address;
- the refreshed plan contains no unintended create, delete, or replacement;
- CDB/PDB ordering remains explicit;
- current DBM and Operations Insights collection is verified after apply; and
- the prior state backup can be restored according to the tested recovery
  procedure.
