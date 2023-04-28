# CIS OCI Landing Zone Alarms Module

![Landing Zone logo](../landing_zone_300.png)

This module manages monitoring alarms in Oracle Cloud Infrastructure (OCI) based on a single configuration object. Alarms enable the active and passive monitoring of OCI resources. OCI Monitoring service uses metrics to monitor resources and alarms to notify interested parties when these metrics meet alarm-specified triggers. Alarms are an important consideration for gaining visibility about the health, capacity and performance of OCI resources, allowing for an informed and agile infrastructure management approach. 

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### IAM Permissions

This module requires the following OCI IAM permissions in the compartments where alarms, topics, and streams are defined. 

For deploying alarms:
```
Allow group <group> to manage alarms in compartment <alarms-compartment-name>
Allow group <group> to read metrics in compartment <compartment-name>
```

For deploying topics:
```
Allow group <group> to manage ons-family in compartment <topic-compartment-name>
```

For deploying streams:
```
Allow group <group> to manage stream-family in compartment <compartment-name>
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
module "alarms" {
  source = "../.."
  alarms_configuration = var.alarms_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the alarms module folder in this repository, as shown:
```
module "alarms" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//alarms"
  alarms_configuration = var.alarms_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//alarms?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, alarms are defined using the *alarms_configuration* object, that supports the following attributes:
- **default_compartment_ocid**: the default compartment for all resources managed by this module. It can be overriden by *compartment_ocid* attribute in each resource.
- **default_defined_tags**: the default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: the default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.
- **alarms**: define the alarms to capture and where to send them. 
- **topics**: define the topics managed by this module that can be used as alarm destinations. 
- **streams**: define the streams managed by this module that can be used as alarm destinations.

**Note**: Each alarm, topic and stream are defined as an object whose key must be unique and must not be changed once defined. As a convention, use uppercase strings for the keys.

## Defining the alarms to trigger

Within the *alarms* attribute, the alarms to trigger can be specific in two ways: through pre-configured alarm types or by supplying specific alarms.
- **pre-configured alarm types**: use the *preconfigured_alarm_type* attributes, assigning it a list of the following supported values: *high-cpu-alarm*, *instance-status-alarm*, *vm-maintenance-alarm*, *bare-metal-unhealthy-alarm*, *high-memory-alarm*, *adb-cpu-alarm*, *adb-storage-alarm*,*vpn-status-alarm* and *fast-connect-status-alarm*. For the list of metrics in each of these types, check [preconfigured_alarms.tf file](./preconfigured_alarms.tf).
- **supplied alarm**: use the *supplied_alarm* attribute, assigning its member attributes:
  - **query**: the Monitoring Query Language (MQL) expression to evaluate for the alarm. Example: "CpuUtilization[1m].mean() > 80".
  - **namespace**: indicator of the resource, service, or application that emits the metric. Example: "oci_computeagent".
  - **pending_duration**: the period of time that the condition defined in the alarm must persist before the alarm state changes from "OK" to "FIRING". For example, a value of 5 minutes means that the alarm must persist in breaching the condition for five minutes before the alarm updates its state to "FIRING". Default is 5 minutes ("PT5M").
  - **severity**: the perceived type of response required when the alarm is in the "FIRING" state. Valid values are: "CRITICAL", "ERROR", "WARNING", "INFO". Default is "CRITICAL".
  - **message_format**: the format to use for notification messages sent from this alarm. Valid values are "RAW", "PRETTY_JSON" and "ONS_OPTMIZED". Default is "PRETTY_JSON".

Check [preconfigured_alarms.tf file](./preconfigured_alarms.tf) as examples on how to define these attributes and [Overview of Monitoring](https://docs.oracle.com/en-us/iaas/Content/Monitoring/Concepts/monitoringoverview.htm) for details on OCI Monitoring service.

**Note**: *supplied_alarm* takes precedence over *preconfigured_alarm_type*.

### Naming Alarms

Use *display_name* attribute to name alarms.

### Defining where to send the triggered alarms

Within the *alarms* attribute, use *destination_topics* and *destination_streams* attributes to define where to send triggered alarms. These attributes are similar, defining the topics, and streams, as target destinations for the alarms in question. *destination_topics* and *destination_streams* support referencing topics and streams managed by this module or externally managed.

- **destination_topics**: use *topic_keys* attribute to refer to managed topics and *existing_topic_ocids* attribute to consume externally managed topics.
- **destination_streams**: use *streams_keys* attribute to refer to managed streams and *existing_stream_ocids* attribute to consume externally managed streams.

For referring to a topic or stream managed by this module, provide the topic or stream key as defined in the *topics* and *streams* attributes (see next subsection).

For referring to an externally managed topic, stream, or function, provide its ocid (Oracle Cloud ID).

The example below shows the two destination types. Note that you can provide multiple keys and existing ocids (they are lists) and both locally managed and externally managed resources can be used together. 
```
destination_topics = {
  topic_keys = ["NETWORK-TOPIC-KEY"] # this key value refers to a topic managed by this module.
  existing_topic_ocids = ["ocid1.onstopic.oc1.iad.aaaaaa...j5q"] # this ocid refers to a topic NOT managed by this module. It is a pre-existing topic that was created through some other means.
}
destination_streams = {
  stream_keys = ["NETWORK-STREAM-KEY"] # this key value refers to a stream managed by this module.
  existing_stream_ocids = ["ocid1.stream.oc1.iad.aaaaaa...ijk"] # this ocid refers to a stream NOT managed by this module. It is a pre-existing stream that was created through some other means.
}
```

## Defining alarm destinations
Within *alarms_configuration*, use the *topics* and *streams* attributes to define the topics and streams destinations managed by this module.

**Each topic and stream is defined as an object whose key must be unique and must not be changed once defined**. As a convention, use uppercase strings for the keys. These keys are referred in *topic_keys* and *stream_keys* attributes in *destination_topics* and *destination_streams*, respectively.

For each topic in the *topics* attribute, you can define their associated *subscriptions*, by specifying  respective *protocol* and *values*. Supported protocols are *EMAIL*, *CUSTOM_HTTPS*, *PAGERDUTY*, *SLACK*, *ORACLE_FUNCTIONS*, *SMS*. Look at https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/create-subscription.htm for details on protocol requirements.

A topic definition example is shown below. Multiple subscriptions and multiple protocols within a subscription are supported.
```
topics = {
  NETWORK-TOPIC-KEY = { # this key is referred by topic_keys within destination_topics attribute
    name = "vision-network-topic"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    subscriptions = [
      { protocol = "EMAIL", values = ["email.address@example.com"]}
    ]  
  }
}    
```

For managed streams, it is possible to specify the number of partitions and the retention (in hours), Their default values are 1 partition and 24 hours, respectively.
```
streams = {
  NETWORK-STREAM-KEY = { # this key is referred by stream_keys within actions_streams attribute
    name = "vision-network-stream"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    num_partitions = 2
    log_retention_in_hours = 48
  }
}
```

## An Example

Here's a sample configuration for sending pre-configured alarms of type "vpn-status-alarm" to a topic that is managed by this module. The topic is subscribed by "email.adress@example.com" email.

```
alarms_configuration = {
  default_compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
  
  alarms = {
    NETWORK-ALARM-VPN-STATUS-KEY : {
      display_name = "vpn-status-alarm"
      preconfigured_alarm_type = "vpn-status-alarm"
      destination_topics = {
        topic_keys = ["NETWORK-TOPIC-KEY"]
      }  
    }
  }
  topics = {
    NETWORK-TOPIC-KEY = {
      compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
      name = "network-topic"
      subscriptions = [
        { protocol = "EMAIL"
          values = ["email.adress@example.com"]
        }
      ]
    }
  }
} 
```

## <a name="related">Related Documentation</a>
- [Overview of Monitoring](https://docs.oracle.com/en-us/iaas/Content/Monitoring/Concepts/monitoringoverview.htm)
- [Overview of Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)
- [Overview of Streaming](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)
- [Monitoring Alarms in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm)
- [Notification Topics in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic)
- [Streams in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream)

## <a name="issues">Known Issues</a>
None.
