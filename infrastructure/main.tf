# ---------------------------------------------------------------------------------------------------------------------
# ZENML INFRASTRUCTURE BOILERPLATE
# ---------------------------------------------------------------------------------------------------------------------
#
# TODO: Add your Terraform configuration here.
#
# Hint: Check out the official ZenML Terraform Modules:
# https://registry.terraform.io/modules/zenml-io/zenml-stack
#
# Your goal is to provision a complete cloud stack (infrastructure + ZenML registration),
# e.g. artifact store, container registry, and a cloud orchestrator.
#
# Terraform terminology (modules vs providers):
# - Providers (e.g. `hashicorp/aws`, `zenml-io/zenml`) expose *resources* you can manage.
# - Modules (e.g. `zenml-io/zenml-stack/aws`) are reusable Terraform packages that
#   provision multiple resources using one or more providers.
#
# In this challenge, you'll typically:
# - use the `zenml-io/zenml-stack/<cloud>` module to provision cloud infra + register a stack
# - use the `zenml-io/zenml` provider directly for additional ZenML resources (e.g. `log_store`)
#
# -------------------------------------------------------------------
# Suggested workflow (high level)
# -------------------------------------------------------------------
# 1) Configure your cloud provider + the ZenML provider
# 2) Instantiate the `zenml-io/zenml-stack/<cloud>` module (creates infra + registers a baseline stack)
# 3) Add a Log Store to the stack (via the ZenML Terraform provider)
#
# Tips:
# - Use `terraform output` and the ZenML dashboard to verify what got created.
# - When stuck, consult:
#   - the module docs: https://registry.terraform.io/modules/zenml-io/zenml-stack
#   - the ZenML Terraform provider docs: https://registry.terraform.io/providers/zenml-io/zenml/latest/docs

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = ">=6.28.0"
    }

    zenml = {
      source = "zenml-io/zenml"
      # version = ">=3.0.4"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# provider "zenml" {
#   # Configuration will be loaded from environment variables:
#   # ZENML_SERVER_URL and ZENML_API_KEY
# }

variable "grafana_otlp_endpoint" {
  description = "OTLP HTTP endpoint for Grafana Cloud logs"
  type        = string
}

variable "grafana_otlp_auth_header" {
  description = "Authorization header value for Grafana Cloud OTLP endpoint, e.g., `Basic MTQxxx...`"
  type        = string
  sensitive   = true
}


# THis will create a ZenML stack on AWS with SageMaker as the orchestrator
module "zenml_stack" {
  # source = "zenml-io/zenml-stack/aws"
  source = "./modules/terraform-aws-zenml-stack"

  zenml_stack_name = "cloud-migration-stack"
  orchestrator     = "sagemaker" # or "skypilot" or "local"

  # Pass Grafana OTLP settings from root variables (populated via TF_VAR_*)
  grafana_otlp_endpoint    = var.grafana_otlp_endpoint
  grafana_otlp_auth_header = var.grafana_otlp_auth_header

  # version = "2.0.10" # latest as of Jan 10 2026
}


# ref: https://registry.terraform.io/modules/zenml-io/zenml-stack/aws/latest?tab=outputs
# I copied the descriptions of the outputs from ^^^above docs

output "zenml_stack_id" {
  description = "The ID of the ZenML stack that was registered with the ZenML server"
  value       = module.zenml_stack.zenml_stack_id
}

output "zenml_stack_name" {
  description = "The name of the ZenML stack that was registered with the ZenML server"
  value       = module.zenml_stack.zenml_stack_name
}

output "zenml_stack" {
  description = "The ZenML stack that was registered with the ZenML server"
  value       = module.zenml_stack.zenml_stack
}
