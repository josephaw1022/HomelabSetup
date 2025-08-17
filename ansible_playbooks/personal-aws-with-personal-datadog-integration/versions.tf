terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
  required_version = ">= 1.6.0"
}
