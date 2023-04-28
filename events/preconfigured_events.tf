# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  preconfigured_events = {
    iam = {
      description = "CIS Landing Zone IAM events."
      conditions = ["com.oraclecloud.identitycontrolplane.createidentityprovider",
                    "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
                    "com.oraclecloud.identitycontrolplane.updateidentityprovider",
                    "com.oraclecloud.identitycontrolplane.createidpgroupmapping",
                    "com.oraclecloud.identitycontrolplane.deleteidpgroupmapping",
                    "com.oraclecloud.identitycontrolplane.updateidpgroupmapping",
                    "com.oraclecloud.identitycontrolplane.addusertogroup",
                    "com.oraclecloud.identitycontrolplane.creategroup",
                    "com.oraclecloud.identitycontrolplane.deletegroup",
                    "com.oraclecloud.identitycontrolplane.removeuserfromgroup",
                    "com.oraclecloud.identitycontrolplane.updategroup",
                    "com.oraclecloud.identitycontrolplane.createpolicy",
                    "com.oraclecloud.identitycontrolplane.deletepolicy",
                    "com.oraclecloud.identitycontrolplane.updatepolicy",
                    "com.oraclecloud.identitycontrolplane.createuser",
                    "com.oraclecloud.identitycontrolplane.deleteuser",
                    "com.oraclecloud.identitycontrolplane.updateuser",
                    "com.oraclecloud.identitycontrolplane.updateusercapabilities",
                    "com.oraclecloud.identitycontrolplane.updateuserstate"]
    }
    network = {
      description = "CIS Landing Zone network events."
      conditions = ["com.oraclecloud.virtualnetwork.createvcn",
                    "com.oraclecloud.virtualnetwork.deletevcn",
                    "com.oraclecloud.virtualnetwork.updatevcn",
                    "com.oraclecloud.virtualnetwork.createroutetable",
                    "com.oraclecloud.virtualnetwork.deleteroutetable",
                    "com.oraclecloud.virtualnetwork.updateroutetable",
                    "com.oraclecloud.virtualnetwork.changeroutetablecompartment",
                    "com.oraclecloud.virtualnetwork.createsecuritylist",
                    "com.oraclecloud.virtualnetwork.deletesecuritylist",
                    "com.oraclecloud.virtualnetwork.updatesecuritylist",
                    "com.oraclecloud.virtualnetwork.changesecuritylistcompartment",
                    "com.oraclecloud.virtualnetwork.createnetworksecuritygroup",
                    "com.oraclecloud.virtualnetwork.deletenetworksecuritygroup",
                    "com.oraclecloud.virtualnetwork.updatenetworksecuritygroup",
                    "com.oraclecloud.virtualnetwork.updatenetworksecuritygroupsecurityrules",
                    "com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment",
                    "com.oraclecloud.virtualnetwork.createdrg",
                    "com.oraclecloud.virtualnetwork.deletedrg",
                    "com.oraclecloud.virtualnetwork.updatedrg",
                    "com.oraclecloud.virtualnetwork.createdrgattachment",
                    "com.oraclecloud.virtualnetwork.deletedrgattachment",
                    "com.oraclecloud.virtualnetwork.updatedrgattachment",
                    "com.oraclecloud.virtualnetwork.createinternetgateway",
                    "com.oraclecloud.virtualnetwork.deleteinternetgateway",
                    "com.oraclecloud.virtualnetwork.updateinternetgateway",
                    "com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment",
                    "com.oraclecloud.virtualnetwork.createlocalpeeringgateway",
                    "com.oraclecloud.virtualnetwork.deletelocalpeeringgateway",
                    "com.oraclecloud.virtualnetwork.updatelocalpeeringgateway",
                    "com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment",
                    "com.oraclecloud.natgateway.createnatgateway",
                    "com.oraclecloud.natgateway.deletenatgateway",
                    "com.oraclecloud.natgateway.updatenatgateway",
                    "com.oraclecloud.natgateway.changenatgatewaycompartment",
                    "com.oraclecloud.servicegateway.createservicegateway",
                    "com.oraclecloud.servicegateway.deleteservicegateway.begin",
                    "com.oraclecloud.servicegateway.deleteservicegateway.end",
                    "com.oraclecloud.servicegateway.attachserviceid",
                    "com.oraclecloud.servicegateway.detachserviceid",
                    "com.oraclecloud.servicegateway.updateservicegateway",
                    "com.oraclecloud.servicegateway.changeservicegatewaycompartment"]

    }
    storage = {
      description = "CIS Landing Zone storage events."
      conditions = ["com.oraclecloud.objectstorage.createbucket",
                    "com.oraclecloud.objectstorage.deletebucket",
                    "com.oraclecloud.blockvolumes.deletevolume.begin",
                    "com.oraclecloud.filestorage.deletefilesystem"]
    }
    database = {
      description = "CIS Landing Zone database events."
      conditions = ["com.oraclecloud.databaseservice.autonomous.database.critical",
                    "com.oraclecloud.databaseservice.dbsystem.critical"]
    }
    exainfra = {
      description = "CIS Landing Zone Exadata Cloud Service events."
      conditions = ["com.oraclecloud.databaseservice.exadatainfrastructure.critical",
                    "com.oraclecloud.databaseservice.autonomous.cloudautonomousvmcluster.critical"]
    }
    budget = {
      description = "CIS Landing Zone budget events."
      conditions = ["com.oraclecloud.budgets.updatealertrule",
                    "com.oraclecloud.budgets.deletealertrule",
                    "com.oraclecloud.budgets.updatebudget",
                    "com.oraclecloud.budgets.deletebudget"]
    }
    compute = {
      description = "CIS Landing Zone compute events."
      conditions = ["com.oraclecloud.computeapi.terminateinstance.begin"]
    }
    cloudguard = {
      description = "CIS Landing Zone Cloud Guard events."
      conditions = ["com.oraclecloud.cloudguard.problemdetected",
                    "com.oraclecloud.cloudguard.problemdismissed",
                    "com.oraclecloud.cloudguard.problemremediated"]
    }
  }
}    