# CIS OCI Notifications Module Example - External Dependency

## Introduction

This example shows how to deploy Notification resources in OCI using the [Notifications module](../..). It is functionally equivalent to [Vision example](../vision/), but it obtains its dependencies from an OCI Object Storage object, specified in *oci_compartments_object_name* variable. 

It deploys two topics:
- A topic for network related notifications subscribed by two email addresses.
- A topic for security related notifications subscribed by a mobile phone number.

This example reads the output of Compartment module (see [main.tf](./main.tf)) and publishes the Notification module output for Topic consumers (see [outputs.tf](./outputs.tf)) from/to OCI Object Storage bucket. As such, the following extra permissions are required for the executing user, in addition to the permissions required by the [Notifications module](../..) itself.

```
allow group <group> to read objectstorage-namespaces in tenancy
allow group <group> to use buckets in compartment <bucket-compartment-name>
allow group <group> to manage objects in compartment <bucket-compartment-name> where target.bucket.name = '<bucket-name>'
```

Note: *<bucket-name>* is the bucket specified by *oci_shared_config_bucket* variable. *<bucket-compartment-name>* is *<bucket-name>*'s compartment.

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *notifications_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-REFERENCE\>* placeholders by the appropriate compartment references, expected to be found in the OCI Object Storage object specified in *oci_compartments_object*.
   - Replace *email.address_1@example.com* and *email.address_2@example.com* by actual email addresses.
   - Replace *\<REPLACE-BY-MOBILE-PHONE-NUMBER\>* placeholder with an actual mobile number for SMS notifications.
   - Replace *\<REPLACE-BY-BUCKET-NAME\>* placeholder by the OCI Object Storage bucket for configuration sharing across modules.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-COMPARTMENTS\>* placeholder by the OCI Object Storage object with the compartments references. This object is tipically stored in OCI Object Storage by the module that manages compartments.
   - Replace *\<REPLACE-BY-OBJECT-NAME-FOR-TOPICS\>* placeholder by the OCI Object Storage object to hold topic references. This object is written to the shared configuration bucket by this example.

The OCI Object Storage object with compartment references is expected to have a structure like this:
```
{
  "NETWORK-CMP" : {
    "id" : "ocid1.compartment.oc1..aaaaaa...tgr"
  }    
  "SECURITY-CMP" : {
    "id" : "ocid1.compartment.oc1..aaaaaa...xuq"
  }
}
```   

Refer to [Notifications module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```