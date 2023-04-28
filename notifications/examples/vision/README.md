# CIS OCI Notifications Module Example - Vision notifications

## Introduction

This example shows how to deploy notifications in OCI for a hypothetical Vision entity. It deploys two topics:
- A topic subscribed by two email addresses.
- A topic subscribed by a mobile phone number.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *notifications_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. 
   - Replace *email.address@example.com* by actual email addresses.
   - Replace *\<REPLACE-BY-MOBILE-PHONE-NUMBER\>* placeholder with an actual mobile number for SMS notifications.

Refer to [Notifications module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```