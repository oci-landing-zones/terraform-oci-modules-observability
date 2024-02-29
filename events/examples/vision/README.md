# CIS OCI Events Module Example - Vision events

## Introduction

This example shows how to deploy event rules in OCI for a hypothetical Vision entity using pre-configured event categories (*preconfigured_events_categories* attribute). The events are the same deployed by [CIS Landing Zone Quick Start](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart).

It creates two sets of event rules in the specified home region and region. IAM and Cloud Guard event rules are created in the home region (defined by *home_region* variable), while all others are created in the region (defined by *region* variable). Each event rule is configured to publish events to a managed topic that is subscribed by one email address.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *events_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. Or utilize the reserved key "TENANCY-ROOT" for the root compartment OCID.
   - Replace *\email.address@example.com\* by actual email addresses.

Refer to [Events module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```