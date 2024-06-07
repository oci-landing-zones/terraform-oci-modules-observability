# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "home_region" {description = "Your tenancy home region"}
variable "region" {description = "Your tenancy region"}
variable "secondary_region" {description = "Your tenancy secondary region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "service_connectors_configuration" {
  description = "Service Connectors configuration settings, defining all aspects to manage service connectors and related resources in OCI. Please see the comments within each attribute for details."
  type = any
}