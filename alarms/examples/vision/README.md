# OCI Alarms Module Example - Vision alarms

## Introduction

This example shows how to deploy alarms in OCI for a hypothetical Vision entity using pre-configured alarms (*preconfigured_alarm_types* attribute). The alarms are the same deployed by [CIS Landing Zone Quick Start](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart).

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *alarms_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. Or utilize the reserved key "TENANCY-ROOT" for the root compartment OCID.
   - Replace *email.address@example.com* by actual email addresses.

Refer to [Alarms' module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```
