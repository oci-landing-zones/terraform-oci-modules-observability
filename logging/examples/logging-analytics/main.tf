module "test_logging" {
  source                = "../.."
  tenancy_ocid          = var.tenancy_ocid
  logging_configuration = var.logging_configuration
}