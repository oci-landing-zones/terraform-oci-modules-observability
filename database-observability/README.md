# OCI Landing Zone Database Observability Module

![Landing Zone logo](../landing_zone_300.png)

This module manages production-oriented Oracle Database observability resources
in Oracle Cloud Infrastructure (OCI) from one configuration object. It creates
or consumes private endpoints, enables Database Management for Base Database
Service and Exadata Database Service CDBs, PDBs, and non-CDBs, and optionally
enables Operations Insights.

The module is structured for publication in the
[OCI Landing Zone Observability Modules](https://github.com/oci-landing-zones/terraform-oci-modules-observability)
repository. It follows that repository's dependency-key convention: each input
ending in `_id` can be a literal OCID or a key in the matching dependency map.

Check the [module specification](./SPEC.md) for the complete input, resource,
and output contract. Check the [examples](./examples/) folder for Base Database
and Exadata Database Service configurations, including JSON variable files.
The [One-OE blueprint fragments](./blueprints/one-oe/) provide source JSON for
the Operating Entities composition workflow.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Production Lifecycle](#lifecycle)
- [External Dependencies](#dependencies)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>

### Terraform and OCI provider

- Terraform `>= 1.5.0, < 2.0.0`
- OCI provider `>= 6.0.0, < 9.0.0`

The provider is not configured inside the module. Authentication is inherited
from the calling stack, allowing OCI Resource Manager, workload principals,
instance principals, security tokens, or a reviewed local profile.

### Existing database prerequisites

- A supported Base Database Service or Exadata Database Service CDB, PDB, or
  non-CDB.
- A private subnet that can reach every selected database listener.
- A Vault secret containing each monitoring-user password. Plaintext passwords
  are not accepted.
- A monitoring user with the grants required by the selected Database
  Management level and Operations Insights.
- PDB targets must reference an `ADVANCED` CDB target in the same configuration.

### IAM permissions

Use least-privilege policies scoped to the compartments and resource principals
that own the deployment. The exact policy names and scopes depend on whether
private endpoints and Vault secrets are created or consumed. A typical policy
review includes permissions to:

```text
Allow group <terraform-operators> to manage db-management-family in compartment <database-compartment>
Allow group <terraform-operators> to manage opsi-family in compartment <database-compartment>
Allow group <terraform-operators> to read virtual-network-family in compartment <network-compartment>
Allow group <terraform-operators> to read secret-family in compartment <vault-compartment>
```

The Database Management service principal also needs permission to read the
selected Vault secrets. Do not copy these illustrative policies unchanged;
review the current OCI IAM policy reference and separate Terraform operator,
service-principal, and database-administrator duties.

## <a name="invoke">How to Invoke the Module</a>

For local development in this repository:

```hcl
module "database_observability" {
  source = "../../database-observability"

  database_observability_configuration = var.database_observability_configuration
  compartments_dependency              = module.landing_zone_compartments.compartments
  vcns_dependency                      = module.landing_zone_network.vcns
  subnets_dependency                   = module.landing_zone_network.subnets
  databases_dependency                 = module.database_platform.databases
  vault_secrets_dependency             = module.database_secrets.secrets
}
```

After publication in the OCI Landing Zone Observability repository, pin a
reviewed release:

```hcl
module "database_observability" {
  source = "github.com/oci-landing-zones/terraform-oci-modules-observability//database-observability?ref=<REVIEWED_RELEASE>"

  database_observability_configuration = var.database_observability_configuration
}
```

Never deploy an unreviewed branch or moving default branch in production.

## <a name="functioning">Module Functioning</a>

The `database_observability_configuration` object has these top-level
attributes:

- `default_compartment_id`: literal compartment OCID, Landing Zone compartment
  key, or `TENANCY-ROOT` when `tenancy_ocid` is provided.
- `default_defined_tags` and `default_freeform_tags`: tags inherited by
  module-created resources.
- `lifecycle_id`: stable 8-64 character ownership identifier.
- `operation_stage`: `ENABLE`, `DISABLE_TARGETS`, or `DISABLE_CDB`.
- `dbm_private_endpoints`: optional Database Management private endpoints
  created by this module.
- `opsi_private_endpoints`: optional Operations Insights private endpoints
  created by this module.
- `databases`: stable map of reviewed database targets.

Every database key becomes part of the Terraform resource address. Do not
rename keys after deployment without a reviewed migration.

### Database targets

Supported `database_type` values are:

| Value | OCI target | Terraform resource |
| --- | --- | --- |
| `CDB` | Base Database or Exadata container database | `oci_database_management_database_dbm_features_management` |
| `PDB` | Base Database or Exadata pluggable database | `oci_database_management_pluggabledatabase_pluggable_database_dbm_features_management` |
| `NON_CDB` | Base Database or Exadata non-container database | `oci_database_management_database_dbm_features_management` |

Each target supplies a database identifier, a Database Management private
endpoint, listener service, and Vault secret reference. Operations Insights is
opt-in per target and requires an Operations Insights private endpoint.

Autonomous Database and external-database lifecycle APIs have different
ownership and provider contracts. They are deliberately not represented as
these cloud-database resources. Use the companion `dbman-opsi` lifecycle for
those families until a separately tested Landing Zone module contract is
published.

### Private endpoints

Private endpoints can be:

- created in `dbm_private_endpoints` or `opsi_private_endpoints`;
- consumed through the matching dependency map; or
- supplied as literal OCIDs.

Production callers should normally pass VCN, subnet, NSG, compartment, database,
and Vault outputs from their owning Landing Zone modules. This module does not
create a VCN, subnet, Vault, secret, database, database user, or broad IAM
policy.

### Operations Insights

`enable_operations_insights = true` creates an
`oci_opsi_database_insight` after Database Management enablement. Credentials
remain Vault-backed. Registration is not collection proof; post-apply
verification must confirm current metrics and insight data.

## <a name="lifecycle">Production Lifecycle</a>

### Enable

Keep the default `operation_stage = "ENABLE"`. CDB resources have an explicit
graph dependency before PDB resources. The module never uses
`can_disable_all_pdbs` or auto-enables unreviewed PDBs.

### Disable

CDB/PDB disablement is intentionally two-stage:

1. Set `operation_stage = "DISABLE_TARGETS"`, create and review a new plan, then
   apply it. Operations Insights resources are removed first; PDBs and non-CDBs
   are disabled while CDBs remain enabled.
2. Confirm target collection has stopped. Set
   `operation_stage = "DISABLE_CDB"`, create a new plan, and review it.
3. The second plan reads every PDB through the current OCI provider data source.
   It fails unless each `DIAGNOSTICS_AND_MANAGEMENT` feature is absent,
   `DISABLED`, or `NOT_ENABLED`.
4. Apply only that unchanged reviewed plan.

No local receipt, copied output, or configuration flag can bypass the second
plan's provider-backed observation.

For a CDB-only target set, there is no child PDB state to verify. A new reviewed
`DISABLE_CDB` plan can therefore disable the CDB directly.

### Destroy and rollback

A normal `terraform destroy` is not the staged disable workflow. For a managed
fleet, first disable Operations Insights and Database Management through
reviewed normal plans, then destroy private endpoints only after dependency and
network checks. Reused dependencies are never owned or deleted by this module.

For upgrades from this repository's earlier module, follow
[MIGRATION.md](./MIGRATION.md). Test provider and module upgrades in a canary
compartment and retain encrypted state backups according to the state owner's
recovery policy.

## <a name="dependencies">External Dependencies</a>

The module supports these dependency maps:

- `compartments_dependency`
- `vcns_dependency`
- `subnets_dependency`
- `network_security_groups_dependency`
- `databases_dependency`
- `managed_databases_dependency`
- `vault_secrets_dependency`
- `dbm_private_endpoints_dependency`
- `opsi_private_endpoints_dependency`

Every map value must contain an `id` attribute. Dependency keys keep Landing
Zone JSON configuration portable and allow producing modules to pass outputs
without copying OCIDs between stacks.

## Security and state

- No variable accepts a plaintext password, private key, wallet content, or
  database host address.
- Vault secret OCIDs are still sensitive topology. Terraform state can contain
  them even when display is suppressed.
- Use an encrypted remote backend with restricted access, tested concurrency
  controls, state recovery, and one Terraform owner.
- Review plans for replacement, deletion, public exposure, and unexpected
  endpoint changes.
- Do not commit `.terraform/`, state, plan files, credentials, or populated
  variable files.

## <a name="related">Related Documentation</a>

- [OCI Database Management overview](https://docs.oracle.com/en-us/iaas/database-management/home.htm)
- [OCI Operations Insights overview](https://docs.oracle.com/en-us/iaas/operations-insights/home.htm)
- [Database Management private endpoints](https://docs.oracle.com/en-us/iaas/database-management/doc/database-management-private-endpoints.html)
- [OCI Terraform provider](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/)
- [OCI Landing Zone Observability Modules](https://github.com/oci-landing-zones/terraform-oci-modules-observability)
- [OCI Landing Zone Operating Entities](https://github.com/oci-landing-zones/oci-landing-zone-operating-entities)

## <a name="issues">Known Issues</a>

- Operations Insights data can take time to become visible after enablement.
- Live provider validation proves the PDB feature state at plan time; the exact
  reviewed plan and normal change-control window are still required for apply.
