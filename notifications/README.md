# CIS OCI Landing Zone Notifications Module

![Landing Zone logo](../landing_zone_300.png)

This module manages notification topics and subscriptions in Oracle Cloud Infrastructure (OCI) based on a single configuration object. OCI Notifications service enables the configuration of communication channels for publishing messages using topics and subscriptions. When a message is published to a topic, the Notifications service sends the message to all of the topic's subscriptions. 

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### IAM Permissions

This module requires the following OCI IAM permissions in the compartments where topics and subscriptions are defined.
```
Allow group <group> to manage ons-family in compartment <compartment-name>
```

### Terraform Version < 1.3.x and Optional Object Type Attributes
This module relies on [Terraform Optional Object Type Attributes feature](https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes), which is experimental from Terraform 0.14.x to 1.2.x. It shortens the amount of input values in complex object types, by having Terraform automatically inserting a default value for any missing optional attributes. The feature has been promoted and it is no longer experimental in Terraform 1.3.x.

**As is, this module can only be used with Terraform versions up to 1.2.x**, because it can be consumed by other modules via [OCI Resource Manager service](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/home.htm), that still does not support Terraform 1.3.x.

Upon running *terraform plan* with Terraform versions prior to 1.3.x, Terraform displays the following warning:
```
Warning: Experimental feature "module_variable_optional_attrs" is active
```

Note the warning is harmless. The code has been tested with Terraform 1.3.x and the implementation is fully compatible.

If you really want to use Terraform 1.3.x, in [providers.tf](./providers.tf):
1. Change the terraform version requirement to:
```
required_version = ">= 1.3.0"
```
2. Remove the line:
```
experiments = [module_variable_optional_attrs]
```
## <a name="invoke">How to Invoke the Module</a>

Terraform modules can be invoked locally or remotely. 

For invoking the module locally, just set the module *source* attribute to the module file path (relative path works). The following example assumes the module is two folders up in the file system.
```
module "notifications" {
  source = "../.."
  notifications_configuration = var.notifications_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the notifications module folder in this repository, as shown:
```
module "notifications" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//notifications"
  notifications_configuration = var.notifications_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//notifications?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, notifications are defined using the *notifications_configuration* object, that supports the following attributes:
- **default_compartment_ocid**: the default compartment for all resources managed by this module. It can be overriden by *compartment_ocid* attribute in each resource.
- **default_defined_tags**: the default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: the default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.
- **topics**: define the notification topics and associated subscriptions. 

## Defining notification topics and subscriptions

Within *notifications_configuration*, use the *topics* attribute to define the topics and subscriptions managed by this module. Each topic is defined as an object whose key must be unique and must not be changed once defined. As a convention, use uppercase strings for the keys.

For each topic, you can define their associated *subscriptions*, by specifying a list of objects composed by *protocol* and *values*. Supported protocols are *EMAIL*, *CUSTOM_HTTPS*, *PAGERDUTY*, *SLACK*, *ORACLE_FUNCTIONS*, *SMS*. Look at https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/create-subscription.htm for details on protocol requirements.

A topic definition example is shown below. Multiple subscriptions and multiple protocols per subscription are supported.
```
topics = {
  NETWORK-TOPIC-KEY = {
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    name = "vision-network-topic"
    subscriptions = [
      { protocol = "EMAIL", values = ["email.address@example.com"]}
    ]  
  }
}    
```

## <a name="related">Related Documentation</a>
- [Overview of Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)
- [Notification Topics in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic)

## <a name="issues">Known Issues</a>
None.