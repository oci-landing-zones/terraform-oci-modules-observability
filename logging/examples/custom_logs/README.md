# CIS OCI Logging Module Example - Custom Logs

## Introduction

This example shows how to deploy custom logs using the [CIS OCI Logging module](../../). It deploys the following resources:
- One log group for all custom logs.
- One simple custom log. 
- One custom log using SYSLOG parser. 
- One custom log using APACHE_ERROR parser

For deploying service logs, refer to [Flow Logs example](../flow_logs/), [Bucket Logs example](../bucket_logs/) or [Vision Service Logs example](../vision/).

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
  - Replace *\<REPLACE-BY-COMPARTMENT-OCID\>* placeholder with appropriate compartment OCID or key (if enabling external dependency).
  - Replace *\<REPLACE-BY-DYNAMIC-GROUP-OCID\>* placeholder with appropriate dynamic group OCID.
  - Replace *\<REPLACE-BY-PATH-FROM-INSTANCE-TO-GET-LOGS-FROM\>* placeholder with path value from the instance from where logs are to be collected. Ex: "/var/log/"
  - *parser_type* valid values are: "NONE", "SYSLOG", "JSON", "CSV", "TSV", "REGEX", "APACHE_ERROR", "MULTILINE", "APACHE2", "AUDITD", "JSON", "CRI".

Refer to [Logging module README.md](../../README.md) for overall attributes usage.

3. In this folder, run the typical Terraform workflow:
```
terraform init
terraform plan -out plan.out
terraform apply plan.out
```