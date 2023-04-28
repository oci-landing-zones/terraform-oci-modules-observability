# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {}
variable "home_region" {description = "Your tenancy home region"}
variable "region" {description = "Your tenancy region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "stream_compartment_ocid" {
  description = "The stream compartment ocid."
  type = string
}

variable "service_connector_compartment_ocid" {
  description = "The service connector compartment ocid."
  type = string
}

variable "logs_compartment_ocids" {
  description = "The logs compartment ocids. Applies to all types of logs except audit logs."
  type = list(string)
}