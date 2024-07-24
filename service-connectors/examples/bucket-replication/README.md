# CIS OCI Service Connectors Module Example - Bucket replication 

## Introduction

This example shows how to deploy service connectors in OCI with a bucket that is replicated in another region.

It deploys one service connector with the following characteristics:
- Captures logging data from other logs than audit logs from a specific compartment and log group.
- Consolidates captured data in an Object Storage bucket, that is managed in the same configuration and replicated in another region.

An Identity and Access Management (IAM) policy is implicitly deployed in the tenancy home region, granting the Service Connector service rights to push data to the Object Storage bucket.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *service_connectors_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholders by appropriate compartment OCIDs. 
   - Replace *\<REPLACE-BY-LOG_GROUP-OCID\>* placeholder by appropriate log group OCID. 
   - Replace *\<REPLACE-BY-REPLICATION-REGION-NAME>* placeholder with desired replication region name like "us-ashburn-1". If you're not replicating buckets, leave this variable undefined.
   - Set the secondary_region variable to the desired replication region name. If you're replicating buckets, this will be the same value as replica_region. If you're not replicating buckets, this will be the same value as the home_region.

Refer to [Service Connectors module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```