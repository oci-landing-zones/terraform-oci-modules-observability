# Base Database example

This example creates Database Management and Operations Insights private
endpoints and enables a reviewed non-container Base Database target. All OCI
resource values are supplied as Landing Zone dependency keys; the example
contains no credentials, private keys, or plaintext database passwords.

1. Copy `input.auto.tfvars.json.template` to an ignored
   `input.auto.tfvars.json`.
2. Replace each placeholder with an owner-reviewed value or populate the
   dependency maps from producing Landing Zone modules.
3. Authenticate through the execution environment, run `terraform init`, and
   review a saved plan before apply.

The Vault secret must contain the monitoring-user password. Terraform state
still contains resource identifiers and secret references, so use an encrypted
remote backend with restricted access.
