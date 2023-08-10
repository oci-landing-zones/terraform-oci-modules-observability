# CIS OCI Streams Module Example - External Dependency

## Introduction

This example shows how to deploy streams in OCI using the [Streams module](../..). It deploys two streams and one custom stream pool. One stream in created in the custom stream pool while the other stream is created in the Default pool. The custom stream pool's stream is encrypted with a customer managed key (*kms_key_id*) and is only reachable by producers and consumers that can access the subnet (*subnet_id*) and is authorized by the security rules in the network security groups (*nsg_ids*). The Default stream does not have those capabilities.

The example obtains its dependencies from OCI Object Storage objects, specified in *oci_compartments_object_name*, *oci_kms_object_name*, and *oci_network_object_name* variables. 

As this example needs to read from an OCI Object Storage bucket, the following extra permissions are required for the executing user, in addition to the permissions required by the [Streams module](../..) itself.

```
allow group <group> to read objectstorage-namespaces in tenancy
allow group <group> to read buckets in compartment <bucket-compartment-name>
allow group <group> to read objects in compartment <bucket-compartment-name> where target.bucket.name = '<bucket-name>'
```

Note: *<bucket-name>* is the bucket specified by *oci_shared_config_bucket* variable. *<bucket-compartment-name>* is *<bucket-name>*'s compartment.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *alarms_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-REFERENCE\>* placeholders by the appropriate compartment references, expected to be found in the OCI Object Storage object specified by *oci_compartments_object*.
   - Replace *\<REPLACE-BY-ENCRYPTION-KEY-REFERENCE\>* placeholder by the appropriate encryption Key reference, expected to be found in the OCI Object Storage object specified by *oci_kms_object_name*.
   - Replace *\<REPLACE-BY-SUBNET-REFERENCE\>* placeholder by the appropriate subnet reference, expected to be found in the OCI Object Storage object specified by *oci_network_object_name*.
    Replace *\<REPLACE-BY-NSG-REFERENCE\>* placeholder by the appropriate network security group reference, expected to be found in the OCI Object Storage object specified by *oci_network_object_name*.
   - Replace *\<REPLACE-BY-BUCKET-NAME\>* placeholder by the OCI Object Storage bucket for configuration sharing across modules.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-COMPARTMENTS\>* placeholder by the OCI Object Storage object with the compartments references. This object is tipically stored in OCI Object Storage by the module that manages compartments.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-ENCRYPTION-KEYS\>* placeholder by the OCI Object Storage object with encryption keys references. This object is tipically stored in OCI Object Storage by the module that manages encryption keys.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-NETWORK\>* placeholder by the OCI Object Storage object with the network resources (subnets and NSGs) references. This 
   object is tipically stored in OCI Object Storage by the module that manages networking.
   
Refer to [Streams module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```