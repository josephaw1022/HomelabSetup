resource "datadog_integration_aws_account" "datadog_integration" {
  account_tags   = var.account_tags
  aws_account_id = var.aws_account_id
  aws_partition  = var.aws_partition

  aws_regions {
    include_all = true
  }

  auth_config {
    aws_auth_config_role {
      role_name = var.datadog_role_name
    }
  }

  resources_config {
    cloud_security_posture_management_collection = true
    extended_collection                          = true
  }

  traces_config {
    xray_services {}
  }

  logs_config {
    lambda_forwarder {}
  }

  metrics_config {
    namespace_filters {}
  }
}
