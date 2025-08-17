variable "datadog_api_key" {
  type        = string
  description = "Datadog API key (or set DD_API_KEY env var)."
  sensitive   = true
  default     = null
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog APP key (or set DD_APP_KEY env var)."
  sensitive   = true
  default     = null
}


variable "datadog_site_url" {
  type        = string
  description = "Datadog site URL (default is US1)."
  default     = null
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID to integrate with Datadog."
}

variable "aws_partition" {
  type        = string
  description = "AWS partition (aws, aws-us-gov, aws-cn)."
  default     = "aws"
}

variable "datadog_role_name" {
  type        = string
  description = "Name of the IAM role assumed by Datadog."
  default     = "DatadogIntegrationRole"
}

variable "account_tags" {
  type        = list(string)
  description = "Optional tags to associate with the Datadog AWS account integration."
  default     = []
}
