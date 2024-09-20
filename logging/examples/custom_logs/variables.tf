# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
variable "tenancy_ocid" {}
variable "region" {description = "Your tenancy region"}
variable "user_ocid" {default = ""}
variable "fingerprint" {default = ""}
variable "private_key_path" {default = ""}
variable "private_key_password" {default = ""}

variable "logging_configuration" {
  description = "Logging configuration settings, defining all aspects to manage logging in OCI. Please see the comments within each attribute for details."
  type = any
}

variable "external_dependency" {
  type = object({
    bucket_name = string
    cmp_dependency = list(string)
  })
  default = null
}