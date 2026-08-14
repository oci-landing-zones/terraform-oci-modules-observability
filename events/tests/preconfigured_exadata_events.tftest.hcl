mock_provider "oci" {}

variables {
  events_configuration = {
    default_compartment_id = "ocid1.compartment.oc1..test"
    event_rules            = {}
  }
}

run "exadata_event_categories_cover_critical_health_and_availability" {
  command = plan

  assert {
    condition = toset(local.preconfigured_events.database.conditions) == toset([
      "com.oraclecloud.databaseservice.autonomous.database.critical",
      "com.oraclecloud.databaseservice.dbsystem.critical",
      "com.oraclecloud.databaseservice.database.critical",
      "com.oraclecloud.databaseservice.dbnode.critical",
      "com.oraclecloud.databaseservice.autonomous.container.database.critical"
    ])
    error_message = "The database category must contain the complete approved Exadata database critical-event set."
  }

  assert {
    condition = toset(local.preconfigured_events.exainfra.conditions) == toset([
      "com.oraclecloud.databaseservice.exadatainfrastructure.critical",
      "com.oraclecloud.databaseservice.autonomous.cloudautonomousvmcluster.critical",
      "com.oraclecloud.databaseservice.autonomous.vmcluster.critical",
      "com.oraclecloud.databaseservice.exadatainfrastructureconnectstatus"
    ])
    error_message = "The exainfra category must contain the complete approved ExaCS and ExaC@C critical and availability event set."
  }
}
