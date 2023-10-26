# CIS OCI Logging Module Example - Flow Logs

## Introduction

This example shows how to deploy flow logs for subnets, VCNs and VNICs located in a compartment in OCI using the *logging_configuration* attribute.

The picture below shows side by side how the various attributes in *logging_configuration* variable within *input.auto.tfvars.template* map to the alarm definition in OCI (as shown in OCI Console). 

![Attributes to OCI mapping](./images/attributes-to-oci-mapping-1.png)
(./images/attributes-to-oci-mapping-2.png)

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *logging_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>*, placeholders by appropriate compartment OCIDs.

Refer to [Logging' module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```