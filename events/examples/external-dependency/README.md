# CIS OCI Events Module Example - External Dependency

## Introduction

This example shows how to deploy Event Rules resources in OCI using the [Events module](../..). It is functionally equivalent to [Vision example](../vision/), but it obtains its dependencies from an OCI Object Storage object, specified in *oci_compartments_dependency* and *oci_topics_dependency* variables settings. 

This example consumes the output of Compartment and Notification modules (see [main.tf](./main.tf)). As such, the following extra permissions are required for the executing user, in addition to the permissions required by the [Events module](../..) itself.

```
allow group <group> to read objectstorage-namespaces in tenancy
allow group <group> to read buckets in compartment <bucket-compartment-name>
allow group <group> to read objects in compartment <bucket-compartment-name> where target.bucket.name = '<bucket-name>'
```

Note: *<bucket-name>* is the bucket specified by *oci_shared_config_bucket* variable. *<bucket-compartment-name>* is *<bucket-name>*'s compartment.


## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *events_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-ROOT-COMPARTMENT-OCID\>* placeholders by the Root compartment (tenancy) OCID.
   - Replace *\<REPLACE-BY-COMPARTMENT-REFERENCE\>* placeholders by the appropriate compartment references, expected to be found in the OCI Object Storage object specified by *oci_compartments_object*.
   - Replace *\<REPLACE-BY-TOPIC-REFERENCE\>* placeholders by the appropriate topic references, expected to be found in the OCI Object Storage object specified by *oci_topics_object*.
   - Replace *\<REPLACE-BY-BUCKET-NAME\>* placeholder by the OCI Object Storage bucket for configuration sharing across modules.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-COMPARTMENTS\>* placeholder by the OCI Object Storage object with the compartments references. This object is tipically stored in OCI Object Storage by the module that manages compartments.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-TOPICS\>* placeholder by the OCI Object Storage object to hold topic references. This object is tipically stored in OCI Object Storage by the module that manages topics.

Refer to [Events module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```