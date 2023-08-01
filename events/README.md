# CIS OCI Landing Zone Events Module

![Landing Zone logo](../landing_zone_300.png)

This module manages arbitrary events in Oracle Cloud Infrastructure (OCI) based on a single configuration object. Events enable automation based on state changes of OCI resources and are a recommendation of Center for Internet Security (CIS) OCI Foundations Benchmark for raising awareness about changes in Identity and Access Management (IAM) and networking resources. 

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### IAM Permissions

This module requires the following OCI IAM permissions in compartments where event rules, topics, subscriptions and streams are managed.

For deploying event rules:
```
Allow group <group> to manage cloudevents-rules in compartment <events-compartment-name>
```

If events are meant to be captured in the root compartment (as in the case of IAM resources), then the following permission is required:
```
Allow group <group> to manage cloudevents-rules in tenancy
```

For deploying topics and subscriptions:
```
Allow group <group> to manage ons-family in compartment <topic-compartment-name>
```

For deploying streams:
```
Allow group <group> to manage stream-family in compartment <stream-compartment-name>
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
module "events" {
  source = "../.."
  events_configuration = var.events_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the events module folder in this repository, as shown:
```
module "events" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//events"
  events_configuration = var.events_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//events?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, events are defined using the *events_configuration* object, that supports the following attributes:
- **default_compartment_id**: the default compartment for all resources managed by this module. It can be overriden by *compartment_id* attribute in each resource. This attribute is overloaded: it can be either a compartment OCID or a reference (a key) to the compartment OCID.
- **default_defined_tags**: the default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: the default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.
- **event_rules**: define the event types to capture and where to send them. **Each event rule is defined as an object whose key must be unique and must not be changed once defined**. As a convention, use uppercase strings for the keys.
- **topics**: define the topics managed by this module that can be used as event destinations. **Each topic is defined as an object whose key must be unique and must not be changed once defined**. As a convention, use uppercase strings for the keys.
- **streams**: define the streams managed by this module that can be used as event destinations. **Each stream is defined as an object whose key must be unique and must not be changed once defined**. As a convention, use uppercase strings for the keys.

 ## Defining the Event Types to Capture

Within *event_rules*, the event types to capture can be specified in two ways: through pre-configured events categories or by supplying specific event types.

- **pre-configured events categories**: use the *preconfigured_events_categories* attribute, assigning it a list of the following supported values: *iam*, *network*, *storage*, *database*, *exainfra*, *compute*, *budget* and *cloudguard*. For the list of event types in each of these categories, check [preconfigured_events.tf file](./preconfigured_events.tf). 
- **supplied events**: use the *supplied_events* attribute, assigning it a list of valid OCI event type names. Event type names are service specific. Look at [Service that Produce Events](https://docs.oracle.com/en-us/iaas/Content/Events/) for event types within each service.

**Note**: *supplied_events* takes precedence over *preconfigured_events_categories*.

Event rules are enabled by default. For disabling a rule, set *is_enabled* attribute to false.

### Naming Events Rules

Use *event_display_name* to name the event rule and *event_description* for the event rule description. *event_description* defaults to *event_display_name* if not provided.

### Events Filtering

The module allows for the specified events (either pre-configured or explicitly supplied) to be filtered. You can filter by an attribute or by a defined tag assigned to the resource for which the event is triggered. Look at [Matching Events with Filters](https://docs.oracle.com/en-us/iaas/Content/Events/Concepts/filterevents.htm) for details. 

For filtering by attribute, use *attributes_filter* attribute, providing a list of objects with attribute name and value. 

The example below matches events for resources with the specified *compartmentId* and *riskLevel*.
```
attributes_filter = [
  {
    attr = "compartmentId" 
    value = ["ocid1.compartment.oc1..aaaaaa...cnq"]
  }
  {
    attr = "riskLevel" 
    value = ["CRITICAL"] 
  }
]
```                     
For filtering by tag, use *tags_filter* atribute, providing a list of defined tags. Within each tag, provide the tag namespace and a list of tag names and values. The example below matches events for resources tagged with *CostCenter*="1" and *OracleEmail*="email.address@example.com" in the *OracleInternalReserved* namespace.
```
tags_filter = [
  {
    namespace = "OracleInternalReserved"
    tags = [{name = "CostCenter", value = "1"}, {name = "OwnerEmail", value = "email.address@example.com"}]
  }
]
```
## Defining Where to Send Events

Within *event_rules* attribute, use the *destination_topic_ids*, *destination_stream_ids* and *destination_function_ids* attributes to define where to send captured events. 

- **destination_topic_ids**: a list of topics to send events to. This attribute is overloaded, i.e., it can be assigned a literal OCID or a reference (a key) to an OCID. When assigned a reference, the module first looks up for the reference in the *topics* attribute for internally managed topics. Then it looks up in the *topics_dependency* variable for externally managed topics.
- **destination_stream_ids**: a list of streams to send events to. This attribute is overloaded, i.e., it can be assigned a literal OCID or a reference (a key) to an OCID. When assigned a reference, the module first looks up for the reference in the *streams* attribute for internally managed streams. Then it looks up in the *stream_dependency* variable for externally managed streams.
- **destination_function_ids**: a list of OCI functions to send events to. This attribute is overloaded, i.e., it can be assigned a literal OCID or a reference (a key) to an OCID. When assigned a reference, the module looks up for the reference in the *functions_dependency* variable for externally managed functions.

The example below shows the three destination types. Note that you can mix and match multiple OCIDs and references. 
```
destination_topic_ids = ["ocid1.onstopic.oc1.iad.aaaaaa...j5q", "NETWORK-TOPIC-KEY"] 
destination_stream_ids = ["ocid1.stream.oc1.iad.aaaaaa...ijk", "NETWORK-STREAM-KEY"] 
destination_function_ids = ["ocid1.fnfunc.oc1.iad.aaaaaa...3bq", "NETWORK-FUNCTION-KEY"]
```

## Defining Event Destinations

Within *events_configuration*, use the *topics* and *streams* attributes to define the topics and streams destinations managed by this module.

**Each topic and stream is defined as an object whose key must be unique and must not be changed once defined**. As a convention, use uppercase strings for the keys. 

For each topic in the *topics* attribute, you can define their associated *subscriptions*, by specifying  respective *protocol* and *values*. Supported protocols are *EMAIL*, *CUSTOM_HTTPS*, *PAGERDUTY*, *SLACK*, *ORACLE_FUNCTIONS*, *SMS*. Look at https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/create-subscription.htm for details on protocol requirements.

A topic definition example is shown below. Multiple subscriptions and multiple protocols within a subscription are supported.
```
topics = {
  NETWORK-TOPIC-KEY = { # this key is referred by topic_keys within actions_topics attribute
    compartment_id = "ocid1.compartment.oc1..aaaaaa...4ja"
    name = "vision-network-topic"
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
    num_partitions = 2
    log_retention_in_hours = 48
  }
}
```
## External Dependencies

External dependencies are resources managed elsewhere that resources managed by this module depend on. The following dependencies are supported:

- **compartments_dependency**: A map of objects containing the externally managed compartments this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the compartment OCID.
- **topics_dependency**: A map of objects containing the externally managed topics this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the topic OCID.
- **streams_dependency**: A map of objects containing the externally managed streams this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the stream OCID.
- **functions_dependency**: A map of objects containing the externally managed OCI functions this module may depend on. All map objects must have the same type and must contain at least an *id* attribute with the function OCID.

## An Example

Here's a sample setting as shown in [api-gateway-events example](./examples/api-gateway-events/README.md). In summary, the setting captures deployment changes in API Gateway (*supplied_events* attribute), filters them by *compartmentId* attribute (*attributes_filter* filter) as well as *CostCenter* and *OwnerEmail* tags in *OracleInternalReserved* namespace (*tags_filter* attribute).
The resulting events are sent to a topic defined by *APIGW-TOPIC-KEY* (*actions_topics* attribute) that is managed in the same configuration. The managed topic is named *apigw-topic* and subscribed by a single email address (*topics* attribute).

```
events_configuration = { 
  
  default_compartment_id = "ocid1.compartment.oc1..aaaaaa...4ja"
  
  event_rules = {
    APIGW-EVENTS-KEY = { 
      event_display_name = "notify-on-api-gateway-deployments"
      event_description = "Monitoring deployment changes in API Gateway"
      supplied_events = ["com.oraclecloud.apigateway.createdeployment.end","com.oraclecloud.apigateway.deletedeployment.end","com.oraclecloud.apigateway.updatedeployment.end"]
      attributes_filter = [{
        attr = "compartmentId"
        value = ["ocid1.compartment.oc1..aaaaaa...5ib"]
      }]
      tags_filter = [
        {
          namespace = "OracleInternalReserved"
          tags = [{name = "CostCenter", value = "1"}, {name = "OwnerEmail", value = "email.address@example.com"}]
        }
      ]
      actions_topics = {
        topic_keys = ["APIGW-TOPIC-KEY"]
      }  
    }
  }
    
  topics = {
    APIGW-TOPIC-KEY = {
      compartment_ocid = ""ocid1.compartment.oc1..aaaaaa...6kc""
      name = "apigw-topic" 
      description = "Topic for API Gateway related notifications"
      subscriptions = [
        { protocol = "EMAIL"
          values = ["email.address@example.com"]
        }
      ]
    }
  }
}  
```

## <a name="related">Related Documentation</a>
- [Overview of Events](https://docs.oracle.com/en-us/iaas/Content/Events/Concepts/eventsoverview.htm)
- [Overview of Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm)
- [Overview of Streaming](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)
- [Events in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/events_rule)
- [Notification Topics in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic)
- [Streams in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream)

## <a name="issues">Known Issues</a>
None.