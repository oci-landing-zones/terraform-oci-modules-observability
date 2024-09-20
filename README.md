# OCI Landing Zone Observability Modules

![Landing Zone logo](./landing_zone_300.png)

Welcome to the [OCI Landing Zones (OLZ) Community](https://github.com/oci-landing-zones)! OCI Landing Zones simplify onboarding and running on OCI by providing design guidance, best practices, and pre-configured Terraform deployment templates for various architectures and use cases. These enable customers to easily provision a secure tenancy foundation in the cloud along with all required services, and reliably scale as workloads expand.

This repository contains Terraform OCI (Oracle Cloud Infrastructure) modules for Observability & Monitoring related resources that help customers align their OCI implementations with the CIS (Center for Internet Security) OCI Foundations Benchmark recommendations.

The following modules are available:
- [Events](./events/)
- [Alarms](./alarms/)
- [Logging](./logging/)
- [Notifications](./notifications/)
- [Streams](./streams/)
- [Service Connectors](./service-connectors/)

Within each module you find an *examples* folder. Each example is a fully runnable Terraform configuration that you can quickly test and put to use by modifying the input data according to your own needs.  

The modules support being a passed an object containing references to OCIDs (Oracle Cloud IDs) that they may depend on. Every input attribute that expects an OCID (typically, attribute names ending in *_id* or *_ids*) can be given either a literal OCID or a reference (a key) to the OCID. While these OCIDs can be literally obtained from their sources and pasted when setting the modules input attributes, a superior approach is automatically consuming the outputs of producing modules. For every module there is a semi-ready fully functional example of running a module with external dependencies. For instance, check the [Notifications module example](./notifications/examples/external_dependency/). The external dependency approach helps with the creation of loosely coupled Terraform configurations with clearly defined dependencies between them, avoiding copying and pasting OCIDs.

Also see [SIEM Integration example](./examples/siem-integration/) for how to combine these modules together in a single Terraform configuration to manage OCI infrastructure for integrating logs and events to an external SIEM system.

## CIS OCI Foundations Benchmark Modules Collection

This repository is part of a broader collection of repositories containing modules that help customers align their OCI implementations with the CIS OCI Foundations Benchmark recommendations:
- [Identity & Access Management](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-iam)
- [Networking](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-networking)
- [Governance](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-governance)
- [Security](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-security)
- [Observability & Monitoring](https://github.com/oracle-quickstart/terraform-oci-cis-landing-zone-observability) - current repository
- [Secure Workloads](https://github.com/oracle-quickstart/terraform-oci-secure-workloads)

The modules in this collection are designed for flexibility, are straightforward to use, and enforce CIS OCI Foundations Benchmark recommendations when possible.

Using these modules does not require a user extensive knowledge of Terraform or OCI resource types usage. Users declare an object defined in JSON or [Terraform HCL](https://developer.hashicorp.com/terraform/language/syntax/configuration) describing the OCI resources according to each module’s specification and minimal Terraform code to invoke the modules. The modules generate outputs that can be consumed by other modules as inputs, allowing for the creation of independently managed operational stacks to automate your entire OCI infrastructure.

## Help

Open an issue in this repository.

## Contributing

This project welcomes contributions from the community. Before submitting a pull request, please [review our contribution guide](./CONTRIBUTING.md).

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security vulnerability disclosure process.

## License

Copyright (c) 2023,2024 Oracle and/or its affiliates.

*Replace this statement if your project is not licensed under the UPL*

Released under the Universal Permissive License v1.0 as shown at
<https://oss.oracle.com/licenses/upl/>.

## Known Issues
None.
