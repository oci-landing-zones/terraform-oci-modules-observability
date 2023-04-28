# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
    SOURCE_LOGGING = "logging"
    SOURCE_STREAMING = "streaming"
    #SOURCE_MONITORING = "monitoring"
    TARGET_OBJECT_STORAGE = "objectstorage"
    TARGET_STREAMING = "streaming"
    TARGET_FUNCTIONS = "functions"
    TARGET_LOGGING_ANALYTICS = "logginganalytics"
    TARGET_NOTIFICATIONS = "notifications"
    SCH_ACTIVE_STATE = "ACTIVE"
    SCH_INACTIVE_STATE = "INACTIVE"
    TASK_LOG_RULE = "logrule"

    sources = [local.SOURCE_LOGGING, local.SOURCE_STREAMING]
    targets = [local.TARGET_OBJECT_STORAGE, local.TARGET_STREAMING, local.TARGET_FUNCTIONS, local.TARGET_LOGGING_ANALYTICS, local.TARGET_NOTIFICATIONS]
    subscription_protocols = ["EMAIL","CUSTOM_HTTPS","SLACK","PAGERDUTY","ORACLE_FUNCTIONS","SMS"]
}