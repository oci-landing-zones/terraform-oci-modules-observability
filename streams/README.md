# CIS OCI Landing Zone Streams Module

![Landing Zone logo](../landing_zone_300.png)

This module manages streams in Oracle Cloud Infrastructure (OCI) based on a single configuration object. OCI Streaming service provides a fully managed, scalable, and durable solution for ingesting and consuming high-volume data streams in real-time. Streams are recommended for use cases where data is produced and processed continually and sequentially in a publish-subscribe messaging model. 

Check [module specification](./SPEC.md) for a full description of module requirements, supported variables, managed resources and outputs.

Check the [examples](./examples/) folder for actual module usage.

- [Requirements](#requirements)
- [How to Invoke the Module](#invoke)
- [Module Functioning](#functioning)
- [Related Documentation](#related)
- [Known Issues](#issues)

## <a name="requirements">Requirements</a>
### IAM Permissions

This module requires the following OCI IAM permissions in the compartments where streams, keys (if encrypting streams with a customer managed key) and networking components (if deploying streams with private endpoints) are defined. 

For deploying streams:
```
Allow group <group> to manage stream-family in compartment <stream-compartment-name>
```

For encrypting streams with a customer managed key:
```
Allow service streaming to use keys in compartment <key-compartment-name> where target.key.id = '<key-ocid>'
Allow group <group> to use key-delegate in compartment <key-compartment-name> where target.key.id = '<key-ocid>'
```

For deploying streams with private endpoints:
```
Allow group <group> to use vnics in compartment <vnic-compartment-name>
Allow group <group> to use network-security-groups in compartment <nsg-compartment-name>
Allow group <group> to use subnets in compartment <subnet-compartment-name>
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
module "streams" {
  source = "../.."
  streams_configuration = var.streams_configuration
}
```

For invoking the module remotely, set the module *source* attribute to the streams module folder in this repository, as shown:
```
module "streams" {
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//streams"
  streams_configuration = var.streams_configuration
}
```
For referring to a specific module version, append *ref=\<version\>* to the *source* attribute value, as in:
```
  source = "git@github.com:oracle-quickstart/terraform-oci-cis-landing-zone-observability.git//streams?ref=v0.1.0"
```
## <a name="functioning">Module Functioning</a>

In this module, streams are defined using the *streams_configuration* object, that supports the following attributes:
- **default_compartment_ocid**: the default compartment for all resources managed by this module. It can be overriden by *compartment_ocid* attribute in each resource.
- **default_defined_tags**: the default defined tags that are applied to all resources managed by this module. It can be overriden by *defined_tags* attribute in each resource.
- **default_freeform_tags**: the default freeform tags that are applied to all resources managed by this module. It can be overriden by *freeform_tags* attribute in each resource.
- **streams**: the streams.
- **stream_pools**: any custom stream pools. 

## Defining Streams

Within *streams_configuration*, use the *streams* attribute to define the streams managed by this module. Each stream is defined as an object whose key must be unique and must not be changed once defined. As a convention, use uppercase strings for the keys.

The *streams* attribute supports the following attributes:
- **name**: the stream name.
- **compartment_ocid**: the ocid of the compartment where the stream and its default stream pool is created.
- **stream_pool_key**: the key referring to a custom stream pool in the *stream_pools* attribute. When this is defined, the stream is created in the same compartment as the referred custom stream pool. When this is not defined, a default stream pool is created and the stream is placed in the same compartment as the default stream pool.
- **num_partitions**: the number of stream partitions. Default is "1" partition.
- **log_retention_in_hours**: defines for how long log messages are kept. Default is "24" hours.
- **defined_tags**: the stream defined tags. *default_defined_tags* is used if this is not defined.
- **freeform_tags**: the stream freeform tags. *default_freeform_tags* is used if this is not defined.

The following example defines a stream with two partitions and a log retention time of fourty-eight hours. As *stream_pool_key* is not defined, the stream is associated with a default stream pool that is also created. Both the stream and the stream pool are created in the compartment defined by *compartment_ocid*.
```
streams = {
  NETWORK-STREAM-KEY = {
    name = "vision-network-stream"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    num_partitions = 2
    log_retention_in_hours = 48
  }
}
```

The following example defines a stream with one partitions and a log retention time of seventy-two hours. As *stream_pool_key* is defined, the stream is associated with the stream pool pointed by "MY-STREAM-POOL-KEY" key in *stream_pools* attribute. The *compartment_ocid* value is ignored, and the stream is created in the stream pool compartment.
```
streams = {
  NETWORK-STREAM-KEY = {
    name = "vision-network-stream"
    compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
    stream_pool_key = "MY-STREAM-POOL-KEY"
    num_partitions = 1
    log_retention_in_hours = 72
  }
}
```

## Defining (Custom) Stream Pools

Within *streams_configuration*, use the *stream_pools* attribute to define custom stream pools managed by this module. Each stream pool is defined as an object whose key must be unique and must not be changed once defined. As a convention, use uppercase strings for the keys. 

In OCI, every stream belongs to a stream pool, that defines common characteristics for all contained streams. If a stream is not explicitly assigned to a stream pool, a default stream pool is created and the stream is assigned to it.

The *stream_pools* attribute supports the following attributes:
- **name**: the stream pool name.
- **compartment_ocid**: the ocid of the compartment where the stream pool and all its associated streams are created.
- **kms_key_ocid**: the ocid of the customer managed key used to encrypt the streams in the stream pool.
- **private_endpoint_settings**: settings for private endpoints. Use this to restrict traffic to streams in the stream pool to a private endpoint, thus avoiding that traffic traverse the Internet. The following attributes are supported:
  - **subnet_ocid**: the ocid of the subnet where the stream pool is placed. This value cannot be changed once assigned.
  - **private_endpoint_ip**: a private IP address that is explicitly assigned to the stream pool. It must be in the CIDR range of the subnet specified by *subnet_ocid*. If not specified, a randomly IP address taken from the subnet IP range is assigned. After the stream pool is created, a custom Fully Qualified Domaind Name (FQDN), pointing to this private IP, is created. The FQDN is then used to access the service instead of the private IP.
  - **nsg_ocids**: a list of Network Security Group (NSG) ocids where the streams in the stream pool are placed. Access to the streams is only possible if allowed by the NSG security rules. This value cannot be changed once assigned.
- **kafka_settings**: settings for the Kafka APIs compatibility layer. The following attributes are supported:
  - **auto_create_topics_enabled**: determines whether topics are automatically created on the server. This is the equivalent to the Kafka setting "auto.create.topics.enable" Default is false.
  - **bootstrap_servers**: the bootstrap servers to use with Kafka client.
  - **log_retention_in_hours**: determines for how long messages are kept in the stream pool streams. Default is 24 hours.
  - **num_partitions**: the number of stream partitions in the stream pool. Default is 1 partition.  
- **defined_tags**: the stream pool defined tags. *default_defined_tags* is used if this is not defined.
- **freeform_tags**: the stream pool freeform tags. *default_freeform_tags* is used if this is not defined.

The following example defines a stream pool where streams are encrypted with a customer managed key (*kms_key_ocid*) and are only reachable by producers and consumers that can access the subnet (*subnet_ocid*) and are authorized by the security rules in the network security groups (*nsg_ocids*). The commented out attributes (preceded by #) are shown for awareness.
```
stream_pools = {
    MY-STREAM-POOL-KEY = {
      name = "vision-stream-pool"
      compartment_ocid = "ocid1.compartment.oc1..aaaaaa...4ja"
      kms_key_ocid = "ocid1.key.oc1..bzqwnr...zsq"
      private_endpoint_settings = {
        subnet_ocid = "ocid1.subnet.oc1..aaaaaa...e7a"
      # private_endpoint_ip = null
        nsg_ocids = "ocid1.networksecuritygroup.oc1..aaaaaa...xlq"
      }
      #kafka_settings = {
      #  auto_create_topics_enabled = false
      #  bootstrap_servers = null
      #  log_retention_in_hours = 24
      #  num_partitions = 1
      #}
      #defined_tags = null
      #freeform_tags = null
    }
  }
```

## <a name="related">Related Documentation</a>
- [Overview of Streaming](https://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm)
- [Streams in Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/streaming_stream)

## <a name="issues">Known Issues</a>
None.
