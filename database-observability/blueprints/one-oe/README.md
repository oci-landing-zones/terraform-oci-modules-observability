# One-OE blueprint fragments

These JSON files are source fragments for the
`oci-landing-zone-operating-entities` configuration/generation workflow. They
follow its uppercase stable-key convention and are intended to be merged into
an observability stack input after the database platform, network, compartment,
managed-database, and Vault secret outputs are known.

They are not standalone deployments. The owning generator or composition root
must:

- resolve every dependency key through the matching module output;
- replace listener-service placeholders from a private reviewed inventory;
- preserve the CDB/PDB parent relationship;
- keep Vault secret values outside JSON and Terraform variables; and
- run a reviewed plan in the selected tenancy and region.

`base-database-service.json` covers a Base Database CDB/PDB pair.
`exadata-database-service.json` covers the One-OE ExaDB-D shared database
compartment and network key convention.
