# ---------------------------------------------------------------------------------------------------------------------
# ZENML PIPELINE BOILERPLATE
# ---------------------------------------------------------------------------------------------------------------------
#
# Use this pipeline to test if your cloud stack is working correctly.
# Feel free to modify the steps or the pipeline structure.

import logging

from zenml import pipeline, step


@step
def loader() -> str:
    """A simple step that returns a string."""
    logging.info("Loading data...")
    return "Hello from the Cloud!"


@step
def processor(data: str) -> str:
    """A simple step that processes data."""
    logging.info(f"Processing data: {data}")
    return data.upper()


@step
def validator(processed_data: str) -> bool:
    """A simple step that validates the processed data."""
    logging.info(f"Validating data: {processed_data}")
    is_valid = len(processed_data) > 0
    logging.info(f"Data is valid: {is_valid}")
    return is_valid


@pipeline
def cloud_migration_pipeline():
    """The pipeline that connects the steps."""
    data = loader()
    processed = processor(data)
    validator(processed)


if __name__ == "__main__":
    # NOTE:
    # - Make sure you are logged in to a remote ZenML server (not `zenml login --local`).
    # - Make sure your Terraform-provisioned stack is set before running:
    #   `zenml stack set <your-stack-name-or-id>`
    cloud_migration_pipeline()