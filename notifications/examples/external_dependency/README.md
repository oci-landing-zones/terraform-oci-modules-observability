# CIS OCI Notifications Module Example - External Dependency

## Introduction

This example shows how to deploy Notification resources in OCI using the [Notifications module](../..). It is functionally equivalent to [Vision example](../vision/), but it obtains its dependencies from an OCI Object Storage object, specified in *oci_compartments_dependency* variable settings. 

It deploys two topics:
- A topic for network related notifications subscribed by two email addresses.
- A topic for security related notifications subscribed by a mobile phone number.

Because it needs to read from OCI Object Storage, the following permissions are required for the executing user, in addition to the permissions required by the [Notifications module](../..) itself.

```
allow group <group> to read objectstorage-namespaces in tenancy
allow group <group> to read buckets in compartment <bucket-compartment-name>
allow group <group> to read objects in compartment <bucket-compartment-name> where target.bucket.name = '<bucket-name>'
```

## Using this example
1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *notifications_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-REFERENCE\>* placeholders by the appropriate compartment references, expected to be found in the OCI Object Storage object named *\<REPLACE-BY-OBJECT-NAME\>* in *oci_compartments_dependency*.
   - Replace *email.address_1@example.com* and *email.address_2@example.com* by actual email addresses.
   - Replace *\<REPLACE-BY-MOBILE-PHONE-NUMBER\>* placeholder with an actual mobile number for SMS notifications.
   - Replace *\<REPLACE-BY-BUCKET-NAME\>* placeholder by the OCI Object Storage bucket that contains the object named *\<REPLACE-BY-OBJECT-NAME\>*.
   - Replace *\<REPLACE-BY-OBJECT-NAME\>* placeholder by the OCI Object Storage object with the compartment references. This object is tipically stored in OCI Object Storage by the module that manages compartments.

The OCI Object Storage object with compartments dependencies (*oci_compartments_dependency*) is expected to have a structure like this:
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