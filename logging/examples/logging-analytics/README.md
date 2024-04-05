# CIS OCI Logging Module Example - Logging Analytics Log Groups

## Introduction

This example shows how to deploy log groups and namespaces for the Logging Analytics service using the [CIS OCI Logging module](../../). It deploys the following resources:
- One Default log group for Logging Analytics.
- One Audit log group for Logging Analytics.
- One namespace for the Logging Analytics service.

## Running This Example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *logging_configuration* input variable, by making the appropriate substitutions:
    - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholder with appropriate compartment OCID or key (if enabling external dependency). 
    - Check in the Oracle Cloud Console if your tenancy has enabled Logging Analytics by visiting the Logging Analytics home page. There will be a dark grey box at the top of the page. On the right hand side of that box, if Logging analytics has *not* been enabled, there will be a welcome notice and a button to "Start Using Logging Analytics". In that case, set *onboard_logging_analytics* to *true*. Otherwise, set it to *false*.
   
   Refer to [Logging module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```