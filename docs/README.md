# ZenML Solutions Engineering Checklist

- [x] Forked the repo, installed dependencies, and ran and deployed the pipeline locally
- [x] Created Terraform scripts to deploy the ZenML stack on AWS with SageMaker as the orchestrator
- [x] Deployed the Terraform scripts to create the ZenML stack on AWS
- [x] Ran the pipeline on the remote stack
- [x] Re-deployed the stack with OTel log store component
- [x] Re-ran the pipeline and verified logs in Grafana Cloud 


# Steps I followed to complete the challenge

## Initial Setup

- Create a AWS_PROFILE named `zenml` OR any name of your choice and set it as run script environment variable.:
    ```shell
    # Activate the profile
    # AWS_PROFILE=zenml
    aws configure sso --profile zenml
    # OR
    aws sso login --profile zenml
    ```

- First, I forked the repo, installed dependencies, and ran and deployed the pipeline locally.
    ```shell
    # add deps
    uv add zenml --extra local --extra server

    # login
    uv run zenml login --local

    # init
    uv run zenml init

    # run the pipeline
    uv run src/run.py

    # deploy the pipeline
    uv run zenml pipeline deploy src.run:cloud_migration_pipeline
    ```

## Deploy ZenML Stack on AWS with SageMaker Orchestrator

- Created a ZenML Pro account
  - Created a `cloud-migration-demo` organization, a `cloud-migration-workspace` workspace, and a `cloud-migration-project` project inside the workspace.
  - Created an API key, and stored it locally in an `.env` file along with the ZenML server URL.
    ```shell
    export ZENML_SERVER_URL="https://cloud.zenml.io"
    export ZENML_API_KEY="your_api_key_here"
    ```

- Next, I filled the Terraform script to deploy the ZenML stack on AWS with SageMaker as the orchestrator.
  - And deployed the Terraform scripts to create the ZenML stack on AWS.
  - ref: [github-aws-zenml-stack](https://github.com/zenml-io/terraform-aws-zenml-stack), [zenml-stack-module-docs](https://registry.terraform.io/modules/zenml-io/zenml-stack/aws/latest)

- THen locally configured ZenML Pro as per the Onboarding guide:
    ```shell
    # local setup - login, init, set deployed stack
    zenml login cloud-migration-workspace  && zenml init && zenml stack set cloud-migration-stack

    # set the project
    zenml project set cloud-migration-project

    # install integrations
    zenml integration install s3 aws --uv

    # I had to install few dependencies manually to get past some errors before running the pipeline
    uv add "sagemaker>=2.237.3,<3.0.0" kubernetes aws-profile-manager
    ```

    The deployed stack:
    ```shell
    ╭─amitraj@laptop ~/repos/zenml-solution-engineering-challenge ‹feat/solution●› ‹.venv› 
    ╰─$ zenml stack describe
                    Stack Configuration                   
    ╭────────────────────┬──────────────────────────────────╮
    │ COMPONENT_TYPE     │ COMPONENT_NAME                   │
    ├────────────────────┼──────────────────────────────────┤
    │ ARTIFACT_STORE     │ cloud-migration-stack-s3         │
    ├────────────────────┼──────────────────────────────────┤
    │ STEP_OPERATOR      │ cloud-migration-stack-sagemaker  │
    ├────────────────────┼──────────────────────────────────┤
    │ IMAGE_BUILDER      │ cloud-migration-stack-codebuild  │
    ├────────────────────┼──────────────────────────────────┤
    │ ORCHESTRATOR       │ cloud-migration-stack-sagemaker  │
    ├────────────────────┼──────────────────────────────────┤
    │ CONTAINER_REGISTRY │ cloud-migration-stack-ecr        │
    ├────────────────────┼──────────────────────────────────┤
    │ DEPLOYER           │ cloud-migration-stack-app-runner │
    ╰────────────────────┴──────────────────────────────────╯
            'cloud-migration-stack' stack (ACTIVE)          
                Labels             
    ╭──────────────────┬───────────╮
    │ LABEL            │ VALUE     │
    ├──────────────────┼───────────┤
    │ zenml:deployment │ terraform │
    ├──────────────────┼───────────┤
    │ zenml:provider   │ aws       │
    ╰──────────────────┴───────────╯
    Stack 'cloud-migration-stack' with id '...' is owned by user <my-email>@gmail.com.
    Dashboard URL: https://cloud.zenml.io/workspaces/cloud-migration-workspace/stacks?id=...
    ```

- While trying to run the pipeline with the SageMaker orchestrator, I got the following errors.

    <p align="center">
        <img src="./images/pipeline-run-deployed-stack.png" alt="Pipeline Run on Deployed Stack" width="800"/>
        <br>
        <em>Pipeline Run on Deployed Stack</em>
    </p>


  - Although the pipeline ran successfully later on after running the setting the orchestrator to asynchronous mode.
  - A RuntimeError Error:
    ```shell
    RuntimeError: Timed out while waiting for pipeline execution to finish. For long-running pipelines we recommend configuring your 
    orchestrator for asynchronous execution. The following command does this for you: 
    `zenml orchestrator update cloud-migration-stack-sagemaker --synchronous=False`
    ```

    <details>
        <summary>RuntimeError Error:</summary>

    ```shell
    To opt out of telemetry, please disable via TelemetryOptOut parameter in SDK defaults config. For more information, refer to https://sagemaker.readthedocs.io/en/stable/overview.html#configuring-and-using-defaults-with-the-sagemaker-python-sdk.
    Steps can take 5-15 minutes to start running when using the Sagemaker Orchestrator.
    There was an issue while extracting the SageMaker Studio URL: An error occurred (AccessDeniedException) when calling the ListDomains operation: User: arn:aws:sts::643766342908:assumed-role/zenml-39163c977f9b/zenml-connector-df5648e5-6c93-4661-a09c-5002a551c756 is not authorized to perform: sagemaker:ListDomains on resource: arn:aws:sagemaker:us-west-2:643766342908:domain/* because no identity-based policy allows the sagemaker:ListDomains action
    Executing synchronously. Waiting for pipeline to finish... 
    At this point you can Ctrl-C out without cancelling the execution.
    ╭─────────────────────────────── Traceback (most recent call last) ────────────────────────────────╮
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/src/run.py:49 in <module>              │
    │                                                                                                  │
    │   46 │   # - Make sure you are logged in to a remote ZenML server (not `zenml login --local`)    │
    │   47 │   # - Make sure your Terraform-provisioned stack is set before running:                   │
    │   48 │   #   `zenml stack set <your-stack-name-or-id>`                                           │
    │ ❱ 49 │   cloud_migration_pipeline()                                                              │
    │   50                                                                                             │
    │                                                                                                  │
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/zen │
    │ ml/pipelines/pipeline_definition.py:1598 in __call__                                             │
    │                                                                                                  │
    │   1595 │   │   │   return self.entrypoint(*args, **kwargs)  # type: ignore[no-any-return]        │
    │   1596 │   │                                                                                     │
    │   1597 │   │   self.prepare(*args, **kwargs)                                                     │
    │ ❱ 1598 │   │   return self._run()                                                                │
    │   1599 │                                                                                         │
    │   1600 │   def _call_entrypoint(self, *args: Any, **kwargs: Any) -> Any:                         │
    │   1601 │   │   """Calls the pipeline entrypoint function with the given arguments.               │
    │                                                                                                  │
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/zen │
    │ ml/pipelines/pipeline_definition.py:1071 in _run                                                 │
    │                                                                                                  │
    │   1068 │   │   │   │   │   │   │   "`zenml login --local`."                                      │
    │   1069 │   │   │   │   │   │   )                                                                 │
    │   1070 │   │   │   │                                                                             │
    │ ❱ 1071 │   │   │   │   submit_pipeline(                                                          │
    │   1072 │   │   │   │   │   snapshot=snapshot, stack=stack, placeholder_run=run                   │
    │   1073 │   │   │   │   )                                                                         │
    │   1074                                                                                           │
    │                                                                                                  │
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/zen │
    │ ml/execution/pipeline/utils.py:103 in submit_pipeline                                            │
    │                                                                                                  │
    │   100 │   │   except RunMonitoringError as e:                                                    │
    │   101 │   │   │   # Don't mark the run as failed if the error happened during                    │
    │   102 │   │   │   # monitoring of the run.                                                       │
    │ ❱ 103 │   │   │   raise e.original_exception from None                                           │
    │   104 │   │   except BaseException as e:                                                         │
    │   105 │   │   │   if (                                                                           │
    │   106 │   │   │   │   placeholder_run                                                            │
    │                                                                                                  │
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/zen │
    │ ml/orchestrators/base_orchestrator.py:416 in run                                                 │
    │                                                                                                  │
    │   413 │   │   │   │   │                                                                          │
    │   414 │   │   │   │   │   if submission_result.wait_for_completion:                              │
    │   415 │   │   │   │   │   │   try:                                                               │
    │ ❱ 416 │   │   │   │   │   │   │   submission_result.wait_for_completion()                        │
    │   417 │   │   │   │   │   │   except KeyboardInterrupt as e:                                     │
    │   418 │   │   │   │   │   │   │   message = (                                                    │
    │   419 │   │   │   │   │   │   │   │   "Run monitoring interrupted, but "                         │
    │                                                                                                  │
    │ /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/zen │
    │ ml/integrations/aws/orchestrators/sagemaker_orchestrator.py:926 in _wait_for_completion          │
    │                                                                                                  │
    │    923 │   │   │   │   │   │   )                                                                 │
    │    924 │   │   │   │   │   │   logger.info("Pipeline completed successfully.")                   │
    │    925 │   │   │   │   │   except WaiterError:                                                   │
    │ ❱  926 │   │   │   │   │   │   raise RuntimeError(                                               │
    │    927 │   │   │   │   │   │   │   "Timed out while waiting for pipeline execution to "          │
    │    928 │   │   │   │   │   │   │   "finish. For long-running pipelines we recommend "            │
    │    929 │   │   │   │   │   │   │   "configuring your orchestrator for asynchronous "             │
    ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
    RuntimeError: Timed out while waiting for pipeline execution to finish. For long-running pipelines we recommend configuring your 
    orchestrator for asynchronous execution. The following command does this for you: 
    `zenml orchestrator update cloud-migration-stack-sagemaker --synchronous=False`
    ```
    </details>

  - AssertionError from `aiobotocore`:
    ```shell
    AssertionError: Session was never entered
    ```

    <details>
        <summary>AssertionError from aiobotocore: Session was never entered</summary>

    ```shell
    ╭─amitraj@laptop ~/repos/zenml-solution-engineering-challenge ‹feat/solution●› ‹zenml-solution-engineering-challenge› 
    ╰─$ ./run run_pipeline         
    Initiating a new run for the pipeline: cloud_migration_pipeline.
    sagemaker.config INFO - Not applying SDK defaults from location: /Library/Application Support/sagemaker/config.yaml
    sagemaker.config INFO - Not applying SDK defaults from location: /Users/amitraj/Library/Application Support/sagemaker/config.yaml
    Reusing existing build d21fbd57-2a3f-4d74-a74c-652d1bb99a01 for stack cloud-migration-stack.
    Archiving pipeline code directory: /Users/amitraj/repos/zenml-solution-engineering-challenge. If this is taking longer than you expected, make sure your source root is set correctly by running zenml init, and that it does not contain unnecessarily huge files.
    Code already exists in artifact store, skipping upload.
    Using a build:
    Image(s): 643766342908.dkr.ecr.us-west-2.amazonaws.com/zenml-39163c977f9b:977ae1de-a848-441c-8dea-6ec34bcb8ec7, 643766342908.dkr.ecr.us-west-2.amazonaws.com/zenml-39163c977f9b:44aa40e9-132f-4ef5-8548-bd76f9ea6da0
    Using user: avr13405@gmail.com
    Using stack: cloud-migration-stack
    artifact_store: cloud-migration-stack-s3
    step_operator: cloud-migration-stack-sagemaker
    image_builder: cloud-migration-stack-codebuild
    orchestrator: cloud-migration-stack-sagemaker
    container_registry: cloud-migration-stack-ecr
    deployer: cloud-migration-stack-app-runner
    Dashboard URL for Pipeline Run: https://cloud.zenml.io/workspaces/cloud-migration-workspace/projects/9e096638-3faa-43bf-a859-6533210fdff2/runs/519b24fe-ddc8-4cfe-a905-59beb9767488
    SageMaker Python SDK will collect telemetry to help us better understand our user's needs, diagnose issues, and deliver additional features.
    To opt out of telemetry, please disable via TelemetryOptOut parameter in SDK defaults config. For more information, refer to https://sagemaker.readthedocs.io/en/stable/overview.html#configuring-and-using-defaults-with-the-sagemaker-python-sdk.
    Popping out 'TrainingJobName' from the pipeline definition by default since it will be overridden at pipeline execution time. Please utilize the PipelineDefinitionConfig to persist this field in the pipeline definition if desired.
    Popping out 'TrainingJobName' from the pipeline definition by default since it will be overridden at pipeline execution time. Please utilize the PipelineDefinitionConfig to persist this field in the pipeline definition if desired.
    Popping out 'TrainingJobName' from the pipeline definition by default since it will be overridden at pipeline execution time. Please utilize the PipelineDefinitionConfig to persist this field in the pipeline definition if desired.
    SageMaker Python SDK will collect telemetry to help us better understand our user's needs, diagnose issues, and deliver additional features.
    To opt out of telemetry, please disable via TelemetryOptOut parameter in SDK defaults config. For more information, refer to https://sagemaker.readthedocs.io/en/stable/overview.html#configuring-and-using-defaults-with-the-sagemaker-python-sdk.
    Steps can take 5-15 minutes to start running when using the Sagemaker Orchestrator.
    There was an issue while extracting the SageMaker Studio URL: An error occurred (AccessDeniedException) when calling the ListDomains operation: User: arn:aws:sts::643766342908:assumed-role/zenml-39163c977f9b/zenml-connector-df5648e5-6c93-4661-a09c-5002a551c756 is not authorized to perform: sagemaker:ListDomains on resource: arn:aws:sagemaker:us-west-2:643766342908:domain/* because no identity-based policy allows the sagemaker:ListDomains action
    Task exception was never retrieved
    future: <Task finished name='Task-28' coro=<ClientCreatorContext.__aexit__() done, defined at /Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/aiobotocore/session.py:35> exception=AssertionError('Session was never entered')>
    Traceback (most recent call last):
    File "/Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/aiobotocore/session.py", line 36, in __aexit__
        await self._client.__aexit__(exc_type, exc_val, exc_tb)
    File "/Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/aiobotocore/client.py", line 644, in __aexit__
        await self._endpoint.http_session.__aexit__(exc_type, exc_val, exc_tb)
    File "/Users/amitraj/repos/zenml-solution-engineering-challenge/.venv/lib/python3.12/site-packages/aiobotocore/httpsession.py", line 111, in __aexit__
        assert self._sessions is not None, 'Session was never entered'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^
    AssertionError: Session was never entered
    Task completed in 0m46.408s
    ```
    </details>

  - During the pipeline run, I also got this Sagemaker Permission Error. Since this was non-blocking, I didn't do anything about it.
      ```shell
      There was an issue while extracting the SageMaker Studio URL: An error occurred (AccessDeniedException) when calling the ListDomains operation: User: arn:aws:sts::643766342908:assumed-role/zenml-39163c977f9b/zenml-connector-df5648e5-6c93-4661-a09c-5002a551c756 is not authorized to perform: sagemaker:ListDomains on resource: arn:aws:sagemaker:us-west-2:643766342908:domain/* because no identity-based policy allows the sagemaker:ListDomains action
      ```

## Adding OpenTelemetry (OTel) Log Store to deployed ZenML Stack

### Setting up Grafana Cloud

- I signed up for Grafana Cloud account (free tier).
  - Followed the onboarding steps and created an OTLP endpoint and an API key for it. Once you login to Grafana Cloud:
    - Go to "Connections" -> "Add a new connection" -> "OpenTelemetry (OTLP)".
    - Copy the OTLP endpoint and the API key.
    <p align="center">
        <img src="./images/grafana-otel-setup.png" alt="Grafana OTel Setup" width="600"/>
        <br>
        <em>Grafana OTel Setup</em>
    </p>
  - Added them to the `.env` file:
    ```shell
    export OTEL_EXPORTER_OTLP_ENDPOINT="" 
    # ^^^Should look something like "https://otlp-gateway-prod-<region>.grafana.net/otlp/v1/logs"

    export OTEL_EXPORTER_OTLP_HEADERS=""
    # ^^^Should look something like "Basic MTQxxxx..."
    ```

  - You could do a simple `curl` command to verify if the logs are being sent to Grafana Cloud:
    ```shell
    curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Basic MTQxxx...<your-token>" \
    -d '{
        "resourceLogs": [{
        "resource": {
            "attributes": [
            {"key": "service.name", "value": {"stringValue": "curl-app"}}
            ]
        },
        "scopeLogs": [{
            "logRecords": [{
            "timeUnixNano": "'"$(($(date +%s)*1000000000))"'",
            "body": {"stringValue": "This is my log line"}
            }]
        }]
        }]
    }' \
    https://otlp-gateway-prod-<region>.grafana.net/otlp/v1/logs
    ```
  - ref: [Grafana Docs](https://grafana.com/docs/grafana-cloud/send-data/otlp/send-data-otlp/), [Cloudflare docs](https://developers.cloudflare.com/workers/observability/exporting-opentelemetry-data/grafana-cloud/)

### Adding OTel Log Store to ZenML Stack via Terraform
- Next, I went on to updating the Terraform script to add the log store resource to the ZenML stack:
  - The [ZenML Stack Component](https://registry.terraform.io/providers/zenml-io/zenml/latest/docs/resources/stack_component) Terraform docs were helpful in figuring out the resource definition and syntax.
  - The [ZenML OTel Log Store docs](https://docs.zenml.io/stacks/stack-components/log-stores/otel) were helpful in figuring out the configuration parameters, the endpoint and the auth headers.

    <details>
        <summary>Terraform code snippet to add OTel Log Store to ZenML Stack</summary>

    ```terraform
    # ZenML Stack Component to add a Log Store to the stack
    # Format: zenml_stack_component.<component_type>.<component_name>
    # ref: https://registry.terraform.io/providers/zenml-io/zenml/latest/docs/resources/stack_component

    # I found the configuration details here:
    # https://docs.zenml.io/stacks/stack-components/log-stores/otel
    resource "zenml_stack_component" "log_store" {
    name   = "otel-log-store"
    flavor = "otel"
    type   = "log_store"

    configuration = {
        endpoint : var.grafana_otlp_endpoint,
        headers : jsonencode({
        Authorization = "Bearer ${var.grafana_otlp_auth_header}"
        })
    }

    labels = {
        created_by = "amit-vikram-raj"
        purpose    = "zenml-solution-engineering-challenge"
    }
    }
    ```
    </details>

### Few problems I ran into this step

- As a Terraform noob, I had trouble understanding how to extend the zenml module to add the log store component.

- Here is what I did at first:
    - I read the [zenml_stack_component docs](https://registry.terraform.io/providers/zenml-io/zenml/latest/docs/resources/stack_component) and [zenml_stack resource docs](https://registry.terraform.io/providers/zenml-io/zenml/latest/docs/resources/stack) and went ahead to create --
      - a `zenml_stack_component` resource for the log store which is good
      - but then I created a new `zenml_stack` resource with the same name as the one created by the module, and referenced all the components from the module along with the new log store component.
    
    - Thiking that, since I am referencing the components IDs from the module, Terraform would treat this `zenml_stack` resource as an alias to the one created by the module and just add the log store component to it.
    
    - Suprise, surprise!!! I learned that Terraform does not work that way and it ended up treating the new `zenml_stack` resource as a new stack and tried to create it, leading to errors since the stack name was already taken.


    <details>
        <summary>Here is how my incorrect Terraform code looked like initially:</summary>

    ```terraform
    ...

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
    source = "zenml-io/zenml-stack/aws"

    zenml_stack_name = "cloud-migration-stack"
    orchestrator     = "sagemaker" # or "skypilot" or "local"

    version = "2.0.10" # latest as of Jan 10 2026
    }

    resource "zenml_stack_component" "log_store" {
    name   = "otel-log-store"
    flavor = "otel"
    type   = "log_store"

    configuration = {
        endpoint : var.grafana_otlp_endpoint, # https://<your-grafana-stack-id>.grafana.net/otlp/v1/logs
        headers : jsonencode({
        Authorization = "Bearer ${var.grafana_otlp_auth_header}"
        })
    }

    labels = {
        created_by = "amit-vikram-raj"
        purpose    = "zenml-solution-engineering-challenge"
    }
    }

    resource "zenml_stack" "cloud_migration_stack" {
    name = module.zenml_stack.zenml_stack_name

    # Mapping the components from the module and adding the log store
    components = {
        artifact_store     = module.zenml_stack.artifact_store.id
        step_operator      = module.zenml_stack.step_operator.id
        image_builder      = module.zenml_stack.image_builder.id
        orchestrator       = module.zenml_stack.orchestrator.id
        container_registry = module.zenml_stack.container_registry.id
        deployer           = module.zenml_stack.deployer.id
        log_store          = zenml_stack_component.log_store.id
        # ^^^Add the log store component
    }

    labels = {
        created_by = "amit-vikram-raj"
        purpose    = "zenml-solution-engineering-challenge"
    }
    }

    ...
    ```
    </details>

* **

- Finally, after some googling and with some help from ChatGPT, I learned that the correct way to do this would be:
  
  - To [download the module code](https://github.com/zenml-io/terraform-aws-zenml-stack/) locally, modify it to add the log store component resource, and then reference the local module in the main Terraform script.

- So, I downloaded the module code, and placed it in a `modules` directory,
  
  - added two variables `grafana_otlp_endpoint` and `grafana_otlp_auth_header` to the module's [`variables.tf`](../infrastructure/modules/terraform-aws-zenml-stack/variables.tf) file
  
    - ^^^I also learned that variables defined in the child module need to be passed from the root module. So I added these variables to the root module's [`main.tf`](../infrastructure/main.tf) file as well.
    
    - I used environment variables `TF_VAR_grafana_otlp_endpoint` and `TF_VAR_grafana_otlp_auth_header` to pass the values to Terraform during `apply`. Check the [run script](../run) for reference.
  
  - modified the [`main.tf`](../infrastructure/modules/terraform-aws-zenml-stack/main.tf) to add the log store component resource and added it to the stack

  - and then referenced the local module in the [main Terraform script](../infrastructure/main.tf) at the root.

- ref: [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules/configuration)

    <details>
        <summary>Here is how my corrected Terraform code looks like:</summary>

    ```terraform
    ...

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

    ...
    ```
    </details>

* **

I wanted to figure out what [configuration parameters](https://registry.terraform.io/providers/zenml-io/zenml/latest/docs/resources/stack_component#configuration-3) and how could I pass my endpoint URL and the auth headers in my log_store component in my Terraform script.

So I went to the ZenML OTel log store [documentation](https://docs.zenml.io/stacks/stack-components/log-stores/otel). The doc had following example mentioned:
```shell
# Create a secret with your API key
zenml secret create otel_auth \
    --api_key=<YOUR_API_KEY>

# Register the log store with the header
zenml log-store register my_otel_logs \
    --flavor=otel \
    --endpoint=https://otel-collector.example.com/v1/logs \
    --headers='{"Authorization": "Bearer {{otel_auth.api_key}}"}'
```

So in my Terraform script, I used `Authorization: Bearer <glc_...>` as the auth header value with my Grafana API Token, which is wrong.

It should be `Authorization: Basic <base64(instance_id:api_key)>` that you get from Grafana Cloud while setting up the OTLP endpoint.

^^^ChatGPT helped me figure this out.

* **

Earlier while running the pipeline on the previously deployed stack, I was getting this warning related to Sagemaker permissions:
```shell
2026-01-11 10:16:19.549 warn There was an issue while extracting the SageMaker Studio URL: An error occurred (AccessDeniedException) when calling the ListDomains operation: User: arn:aws:sts::<account-id>:assumed-role/zenml-39163c977f9b/zenml-connector-df5648e5-6c93-4661-a09c-5002a551c756 is not authorized to perform: sagemaker:ListDomains on resource: arn:aws:sagemaker:us-west-2:<account-id>:domain/* because no identity-based policy allows the sagemaker:ListDomains action 
```

So I also added the `sagemaker:ListDomains` permission to the IAM role created by the Terraform module for the ZenML connector. I asked ChatGPT to do this.
```terraform
resource "aws_iam_role_policy" "sagemaker_list_domains_policy" {
  count = var.orchestrator == "sagemaker" ? 1 : 0
  name  = "SageMakerListDomainsPolicy"
  role  = aws_iam_role.stack_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sagemaker:ListDomains"],
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/*"
      }
    ]
  })
}
```

## Re-deploying the Stack and Running the Pipeline

And after all that, I was able to successfully re-deploy the stack and run the pipeline on the remote stack with the OTel log store added.

The deployed stack:
```shell
╭─amitraj@laptop ~/repos/zenml-solution-engineering-challenge ‹feat/solution●› ‹.venv› 
╰─$ uv run zenml stack describe                                                         
                     Stack Configuration                     
╭────────────────────┬──────────────────────────────────────╮
│ COMPONENT_TYPE     │ COMPONENT_NAME                       │
├────────────────────┼──────────────────────────────────────┤
│ ARTIFACT_STORE     │ cloud-migration-stack-s3             │
├────────────────────┼──────────────────────────────────────┤
│ STEP_OPERATOR      │ cloud-migration-stack-sagemaker      │
├────────────────────┼──────────────────────────────────────┤
│ IMAGE_BUILDER      │ cloud-migration-stack-codebuild      │
├────────────────────┼──────────────────────────────────────┤
│ LOG_STORE          │ cloud-migration-stack-otel-log-store │
├────────────────────┼──────────────────────────────────────┤
│ ORCHESTRATOR       │ cloud-migration-stack-sagemaker      │
├────────────────────┼──────────────────────────────────────┤
│ CONTAINER_REGISTRY │ cloud-migration-stack-ecr            │
├────────────────────┼──────────────────────────────────────┤
│ DEPLOYER           │ cloud-migration-stack-app-runner     │
╰────────────────────┴──────────────────────────────────────╯
           'cloud-migration-stack' stack (ACTIVE)            
             Labels             
╭──────────────────┬───────────╮
│ LABEL            │ VALUE     │
├──────────────────┼───────────┤
│ zenml:deployment │ terraform │
├──────────────────┼───────────┤
│ zenml:provider   │ aws       │
╰──────────────────┴───────────╯
Stack 'cloud-migration-stack' with id '77b7390f-8dd7-4bef-a344-ed8c9f1539a3' is owned by user 
avr13405@gmail.com.
Dashboard URL: 
https://cloud.zenml.io/workspaces/cloud-migration-workspace/stacks?id=77b7390f-8dd7-4bef-a344-ed8c9f1539a3
```


<p align="center">
    <img src="./images/pipeline-run-with-otel-log-store.png" alt="Pipeline Run with OTel Log Store" width="1000"/>
    <br>
    <em>Pipeline Run with OTel Log Store</em>
</p>

<p align="center">
    <img src="./images/zenml-otel-grafana-logs.png" alt="Pipeline Run Logs in Grafana Cloud" width="1000"/>
    <br>
    <em>Pipeline Run Logs in Grafana Cloud</em>
</p>
