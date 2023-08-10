# CIS OCI Streams Module Example - Vision streams

## Introduction

This example shows how to deploy streams in OCI for a hypothetical Vision entity. It deploys one stream in one custom stream pool. The stream is created in the same compartment as the stream pool. The streams in the stream pool are encrypted with a customer managed key (*kms_key_id*) and are only reachable by producers and consumers that can access the subnet (*subnet_id*) and are authorized by the security rules in the network security groups (*nsg_ids*).

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *streams_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. 
   - Replace *\<REPLACE-BY-VAULT-KEY-OCID\>* placeholder by an appropriate vault key OCID.
   - Replace *\<REPLACE-BY-SUBNET-OCID\>* placeholder by an appropriate subnet OCID.
   - Replace *\<REPLACE-BY-NSG-OCID\>* placeholder by an appropriate network security group OCID.
   
Refer to [Streams module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```