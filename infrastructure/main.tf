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
    # Example for AWS:
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }

    # Example for GCP:
    # google = {
    #   source  = "hashicorp/google"
    #   version = "~> 6.0"
    # }

    # Example for Azure:
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 4.0"
    # }

    zenml = {
      source = "zenml-io/zenml"
    }
  }
}

# TODO: Configure your cloud provider
# provider "aws" {
#   region = var.aws_region
# }

# TODO: Configure ZenML provider
# provider "zenml" {
#   # Configuration will be loaded from environment variables:
#   # ZENML_SERVER_URL and ZENML_API_KEY
# }

# TODO: Use the ZenML stack module for your chosen cloud provider.
# This provisions cloud resources AND registers the resulting stack in your ZenML server.
# module "zenml_stack" {
#   source = "zenml-io/zenml-stack/aws"
#   # or "zenml-io/zenml-stack/gcp"
#   # or "zenml-io/zenml-stack/azure"
#
#   # Recommended: pin a version (see the Terraform registry for latest).
#   # version = "x.y.z"
#
#   zenml_stack_name = "cloud-migration-stack"
#   # Pick a cloud orchestrator:
#   # - AWS: "sagemaker" (default)
#   # - GCP: "vertex" (default)
#   # - Azure: typically "skypilot" / "azureml" depending on module capabilities
#   orchestrator = "sagemaker"
# }

# TODO: Add outputs for important values
# output "zenml_stack_id" {
#   value = module.zenml_stack.zenml_stack_id
# }