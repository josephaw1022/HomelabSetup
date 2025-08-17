provider "aws" {}

# Prefer environment variables DD_API_KEY / DD_APP_KEY instead of tfvars.
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.us5.datadoghq.com/"
}
