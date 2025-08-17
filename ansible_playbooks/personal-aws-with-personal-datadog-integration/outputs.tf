output "datadog_external_id" {
  description = "External ID that Datadog expects when assuming the role."
  value       = datadog_integration_aws_account.datadog_integration.auth_config.aws_auth_config_role.external_id
  sensitive   = true
}

output "iam_role_arn" {
  description = "ARN of the Datadog integration IAM role."
  value       = aws_iam_role.datadog_aws_integration.arn
}

output "iam_policy_arn" {
  description = "ARN of the Datadog integration IAM policy."
  value       = aws_iam_policy.datadog_aws_integration.arn
}
