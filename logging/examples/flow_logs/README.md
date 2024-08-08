# OCI Logging Module Example - Flow Logs in Bulk

## Introduction

This example shows how to deploy flow logs for subnets, VCNs and VNICs in bulk using the [CIS OCI Logging module](../../). The target resources are dynamically retrieved based on the specified target compartments (*target_compartment_ids* attribute) and target resource type (*target_resource_type* attribute). It deploys the following resources:
- One log group.
- One flow log for each retrieved subnet. 

Valid values for *target_resource_type* are "vcn", "subnet", or "vnic":
- **vcn**: flow logs are created for all VCNs under the compartments specified by *target_compartment_ids* attribute.
- **subnet**: flow logs are created for all subnets under the compartments specified by *target_compartment_ids* attribute.
- **vnic**: flow logs are created for the VNICs under the compartments specified by *target_compartment_ids* attribute. It includes Network Load Balancers VNICs, if any.

For deploying flow logs for individual resources, refer to [Vision Service Logs example](../vision/).
For deploying custom logs, refer to [Custom Logs example](../custom_logs/).

## External Dependency (Optional)

This example supports the usage of a JSON file where compartment OCIDs are looked up based on their keys. This file is typically the output of [CIS Landing Zone compartments module](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam/tree/main/compartments) and is assumed to be available as an OCI Object Storage bucket object.
This mechanism allows for specifying a key in *input.auto.tfvars.template* input file instead of a compartment OCID anywhere where a compartment OCID is expected. The Logging module looks up for this key in the JSON file and the compartment OCID is retrieved. The typical structure of the JSON file is the following:
```
{
  "APP-CMP" : {
    "id" : "ocid1.compartment.oc1..aaaaaa...zrt"
  },
  "NETWORK-CMP" : {
    "id" : "ocid1.compartment.oc1..aaaaaa...rtm"
  }
}
```

The JSON file is referred in the *external_dependency* variable settings, where a bucket name and object name are expected.
```
external_dependency = {
  bucket_name      : "<REPLACE-BY-BUCKET-NAME>"
  cmp_dependency   : ["<REPLACE-BY-OBJECT-NAME>"]
}
```

**Note**: The *external_dependency* variable declaration is commented out in *input.auto.tfvars.template*. Uncomment it to enable the external dependency feature.

Code in [external_dependency.tf](./external_dependency.tf) reads the bucket and obtains the file. In [main.tf](./main.tf) the file is passed as an input the Logging module.

For using this feature, as the example reads from an OCI Object Storage bucket, the following extra permissions are required for the executing user, in addition to the permissions required by the [Logging module](../..) itself.

```
allow group <group> to read objectstorage-namespaces in tenancy
allow group <group> to read buckets in compartment <bucket-compartment-name>
allow group <group> to read objects in compartment <bucket-compartment-name> where target.bucket.name = '<bucket-name>'
```

Note: *\<bucket-name\>* is the bucket specified by *external_dependency's* *bucket_name* attribute. *\<bucket-compartment-name\>* is *\<bucket-name\>*'s compartment name.

## Running This Example

1. Rename *input.auto.tfvars.template* to *\<project-name\>.auto.tfvars*, where *\<project-name\>* is any name of your choice.

2. Within *\<project-name\>.auto.tfvars*, provide tenancy connectivity information and adjust the *logging_configuration* input variable, by making the appropriate substitutions:
   - Replace *\<REPLACE-BY-COMPARTMENT-\*\>*, placeholders by appropriate compartment OCIDs or keys (if enabling external dependency).

Refer to [Logging module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```
