# How to Migrate Your ZenML Pipeline to AWS

For the details of building this solution, please refer to [docs/README.md](./docs/README.md).

## Setup

Assumes you have an AWS account.

1. Install [uv](https://docs.astral.sh/uv/getting-started/installation/) and [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. Sign up for [ZenML Pro](https://cloud.zenml.io/signup) and create a workspace & project. Get your Workspace URL and API Key
<p align="center">
    <img src="./docs/images/zenml-workspace-url.png" alt="ZenML Workspace URL" width="600"/>
    <br>
    <em>ZenML Workspace URL</em>
    <br>
    <img src="./docs/images/zenml-api-token.png" alt="ZenML API Key" width="600"/>
    <br>
    <em>ZenML API Key</em>
</p>

3. Signup for [Grafana Cloud](https://grafana.com/auth/sign-up/create-user), use this [YouTube guide](https://youtu.be/nVdeKPRYmmQ?si=bcuA308dckK-2hUN). Once you login to Grafana Cloud:
    - Go to "Connections" -> "Add a new connection" -> "OpenTelemetry (OTLP)".
    - Copy the OTLP endpoint and the API key.
    <p align="center">
        <img src="./docs/images/grafana-otel-setup.png" alt="Grafana OTel Setup" width="600"/>
        <br>
        <em>Grafana OTel Setup</em>
    </p>


4. Use the provided `.env.example` file to create a `.env` file in the root directory. Populate it with your credentials:
    ```shell
    # .env
    export ZENML_SERVER_URL=""
    export ZENML_API_KEY=""

    export OTEL_EXPORTER_OTLP_ENDPOINT="" 
    # ^^^Should look something like "https://otlp-gateway-prod-<region>.grafana.net/otlp/v1/logs"

    export OTEL_EXPORTER_OTLP_HEADERS=""
    # ^^^Should look something like "Basic MTQxxxx..."
    ```

5. Configure your AWS credentials (using SSO or access keys)
    ```shell
    # Activate your aws profile
    aws sso login --profile <your-aws-profile>
    # OR
    aws configure sso --profile <your-aws-profile>

    # Make sure to set the AWS_PROFILE & AWS_REGION in the run script
    ```

6. Deploy the infrastructure and run the pipeline

    ```bash
    # Deploy the infrastructure
    ./run tf_init       # Initialize Terraform
    ./run deploy_infra  # Deploy the infrastructure

    # Configure ZenML to use the remote stack
    zenml login <your-workspace>
    zenml init
    zenml stack set cloud-migration-stack
    zenml project set <your-project>

    # Use the run script to execute the pipeline
    ./run run_pipeline

    # to teardown the infra later
    ./run destroy_infra
    ```

## Terraform Code

All Terraform files are located in the `infrastructure/` directory.

* `main.tf` provisions the entire AWS stack using a local copy of the [ZenML Terraform module](https://registry.terraform.io/modules/zenml-io/zenml-stack/aws/latest).
* The module is extended to include an OTEL log store component for centralized logging.

## Pipeline Execution

<p align="center">
    <img src="./docs/images/pipeline-run-with-otel-log-store.png" alt="Pipeline Run with OTel Log Store" width="1000"/>
    <br>
    <em>Pipeline Run with OTel Log Store</em>
</p>


The `src/run.py` script has been used to:

* Validate the cloud-based ZenML stack
* Trigger and complete a successful pipeline run on AWS SageMaker orchestrator

## Log Store Integration

A ZenML `log_store` component of flavor `otel` is registered using Terraform and attached to the stack.

* Logs are sent to Grafana Cloud via the OTLP HTTP endpoint
* Secrets (like the Grafana API key) are passed securely via `TF_VAR_` environment variables and not hardcoded

## Documentation

### What is a Log Store?

A log store in ZenML captures and centralizes logs from pipeline runs (stdout, logging, etc.). This improves observability and debugging in production setups.

### Where to Find Logs?

<p align="center">
    <img src="./docs/images/zenml-otel-grafana-logs.png" alt="Grafana Logs UI" width="1000"/>
    <br>
    <em>Grafana Cloud UI showing logs from ZenML pipeline</em>
</p>

* Logs are exported to **Grafana Cloud Logs UI** via the OTEL log store
* Navigate to your Grafana workspace home → Drilldown → Logs → Filter by `service.name`

### Architecture Summary

| Component Type     | Technology                   | Purpose                           |
| ------------------ | ---------------------------- | --------------------------------- |
| Artifact Store     | AWS S3                       | Store pipeline inputs/outputs     |
| Container Registry | AWS ECR                      | Store container images            |
| Orchestrator       | AWS SageMaker                | Run pipeline steps                |
| Step Operator      | AWS SageMaker                | Execute individual steps          |
| Image Builder      | AWS CodeBuild                | Build Docker images for pipelines |
| Deployer           | AWS App Runner               | for model serving                 |
| Log Store          | OTEL (Grafana Cloud backend) | Export logs to Grafana            |

**Trust Boundaries & Secrets**:

* ZenML Pro assumes roles in AWS using Service Connectors
* Grafana OTLP credentials passed as env vars via Terraform (`TF_VAR_...`)

## Cost Considerations

<p align="center">
<img src="./docs/images/sagemaker-training-job.png" alt="SageMaker Training Job" width="800"/>
<br>
<em>SageMaker Training Job Running the Pipeline Step</em>
</p>

The deployed stack provisions the following AWS resources:
- [S3](https://aws.amazon.com/s3/pricing/) for Artifact Store
- [ECR](https://aws.amazon.com/ecr/pricing/) for Container Registry
- [SageMaker](https://aws.amazon.com/sagemaker/ai/pricing/) for Orchestrator and Step Operator
- [CodeBuild](https://aws.amazon.com/codebuild/pricing/) for building container images
- [App Runner](https://aws.amazon.com/apprunner/pricing/) for model deployment
- Log Store using Grafana Cloud (free tier)


The pricing for each of these components can vary based on usage, region, and specific configurations.

For instance:

* For the sample pipeline provided, the Sagemaker training job runs on an `ml.m5.xlarge` instance, which runs for ~69 seconds, with $0.23/hour pricing, for 4vCPUs and 16GB RAM.
  * The AWS free tier offers 50 hours of training time on `m4.xlarge` or `m5.xlarge` instances

* The S3 costs depend on the amount of data stored and the number of requests made.

* *The AWS Cost Management Console can help you monitor and estimate your costs based on actual usage.*

AWS Free Tier:
  - As of July 15th 2025, the new [AWS Free Tier](https://aws.amazon.com/free/) provides upto $200 of free credits for new users for upto 6 months.
  
  - >This [awesome video](https://youtu.be/V6yBzR_Ycms?si=ola_Gjq4OX6aC0BH) by Be A Better Dev explains how the new AWS Free Tier works.

## Demo Video

[Video Link]()
