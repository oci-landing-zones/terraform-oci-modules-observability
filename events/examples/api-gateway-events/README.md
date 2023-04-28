# OCI Events Module Usage Example - API Gateway 

## Introduction

This example shows how to manage events related to API Gateway deployments in Oracle Cloud Infrastructure using supplied event type names (*supplied_events* attribute). It also shows how to filter events by attribute and by tag.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *events_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. 
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID-TO-FILTER-ON\>* placeholder by an appropriate compartment OCID. 
   - Replace *email.address@example.com* by actual email addresses.

Refer to [Event's module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```