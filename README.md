# ZenML Solutions Challenge — The Cloud Migration (4h)

**Amit:**

* The [SOLUTION.md](./SOLUTION.md) file contains the brief documentation for the solution.

* The [docs/README.md](./docs/README.md) file contains detailed steps on how I set up everything, the errors I faced, and how I resolved them.

* AI wasn't used in writing any code, however I did ask ChatGPT to write me the things I need to learn to complete the challenge.
  * TBH, I didn't follow it through, because it was quite long😂. So I wrote a checklist for myself which you can read it my detailed docs
  * On few specific errors, I did ask ChatGPT for help in debugging them. I have mentioned those instances in my detailed docs.

* Also I did do parts of Hashicorp's Terraform [AWS tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) to get some familiarity with Terraform.


## Overview 🌟

At ZenML, we are the bridge between the Data Science world and the Infrastructure world. A massive part of your role as a Solutions Engineer is helping customers move from "running on my laptop" to "running on the cloud" without the headache.

For this challenge, you will act as a Solutions Engineer helping a fictional customer, Acme AI, migrate their local stack to the cloud.

## The Scenario 🧠

**Acme AI** has a team of Data Scientists who love ZenML. They have been running pipelines locally, but they are ready to scale.

- **The Goal**: They want to run their pipelines on cloud infrastructure (AWS/GCP/Azure).
- **The Problem**: They are intimidated by the infrastructure setup.
- **Your Job**: Build a "Golden Path" prototype using Terraform and ZenML, and create a guide showing them how to use it.

## Your Task ⚡

### 1. The Infrastructure (Terraform) 🏗️

We don't want you to reinvent the wheel. We want you to use the tools we already have.

**Requirement**: Use the [Official ZenML Terraform Modules](https://registry.terraform.io/modules/zenml-io/zenml-stack) to provision a complete remote stack on the cloud provider of your choice.

#### Terraform terminology (modules vs providers)
If you're new to Terraform, this is the key distinction:

- **Terraform provider**: a plugin that lets Terraform talk to an API (e.g. AWS, GCP, Azure, **ZenML**) and exposes **resources** like `zenml_stack`, `zenml_stack_component`, etc.
- **Terraform module**: a reusable package of Terraform code that typically uses one or more providers under the hood.

In this challenge you will use **both**:

- the **ZenML stack module** (`zenml-io/zenml-stack/<cloud>`) to provision the cloud resources and register a baseline stack
- the **ZenML Terraform provider** (`zenml-io/zenml`) to declaratively add/attach extra ZenML components (like a `log_store`)

This includes:
- **Artifact Store** (S3/GCS/Azure Blob)
- **Container Registry** (ECR/GCR/ACR)
- **Orchestrator** (SageMaker/Vertex AI/Azure ML)

**Why this stack?** This is the most common migration path for customers moving from local development to production.

### 1.5 Log Stores (Terraform-managed) 🪵

In production, customers will ask: **"Where do I find the logs for this run / step?"** This task ensures your stack has a clear, centralized answer.

#### What is a Log Store?
A **Log Store** is a ZenML stack component responsible for collecting, storing, and retrieving logs generated during pipeline and step execution. It captures:

- standard Python `logging`
- `print()` statements
- anything written to `stdout` / `stderr`

If you don't configure a log store, ZenML will fall back to an **Artifact Log Store** (stores logs in your artifact store). For this challenge, we want you to **explicitly configure** a log store so the setup is clear and reproducible.

#### How it fits into a stack
A ZenML **stack** is a collection of components (orchestrator, artifact store, container registry, ...). The **log store** is the component that defines **where execution logs go** and how you access them during debugging.

#### Requirement: register + attach a Log Store using Terraform
Extend your Terraform to:

1. **Register a log store** in ZenML (via Terraform)
2. **Attach it to a stack** (so the active stack uses it)
3. **Prove it works** by running the pipeline and showing logs for at least one step

**Implementation hint (important):** the official `zenml-io/zenml-stack/<cloud>` module provisions cloud resources *and* registers a stack, but it doesn't configure log stores for you. You'll add this as an extra layer in your Terraform.

**Terraform hint (to avoid ambiguity):** Log Stores are stack components. Use the ZenML Terraform provider to:

1. create a `zenml_stack_component` with `type = "log_store"` (choose a flavor like `otel`)
2. create / update a `zenml_stack` resource whose `components` map includes a `log_store = <your log store component id>` entry

If you're unsure about the exact schema, consult the ZenML Terraform provider docs for `zenml_stack_component` and `zenml_stack` resources.

#### Recommended (free) choice: OTEL Log Store + a free OTLP endpoint
Use the built-in **OpenTelemetry (`otel`) log store flavor** and send logs to an **OTLP/HTTP endpoint**.

- **Backend**: use any OTEL-compatible backend that offers a free tier / trial (e.g. Grafana Cloud, Honeycomb, Dash0) or any endpoint you already have.
- **Auth**: do **not** commit secrets; pass auth headers using Terraform variables or environment variables.

> Note: the OTEL log store is generally **write-only** (export only). That's OK: show the logs in the external backend UI.

#### Stretch (optional): secure it properly
Use **ZenML secrets** for any API keys and reference those secrets from your log store configuration (no plaintext secrets in Terraform or git).

### 2. Use a remote ZenML server 🔄

To use the Terraform modules, you’ll need a **remote ZenML server** (not `zenml login --local`).

- **Recommended**: use **ZenML Pro** — sign up at `cloud.zenml.io`.
  - When you sign up, you should already have **~2 days of access**.
  - If you need more time, email `careers@zenml.io` and we can extend your trial so you don’t have to deploy ZenML yourself.
- **Optional**: self-host **ZenML OSS** if you prefer. See [these docs](https://docs.zenml.io/deploying-zenml/deploying-zenml) to learn more.

### 3. The "Solution" (Content) 📚

**Requirement**: Create a clear, customer-facing guide (you can overwrite this README or create a `SOLUTION.md`) that explains how to provision the stack and run the included pipeline.

**Requirement**: Record a **Loom video (exactly 5 minutes)** acting as if you are demoing this solution to the customer. In your video:
- Walk through the Terraform setup (1-2 mins)
- Show the ZenML stack registration (1-2 mins)
- Demonstrate the pipeline running successfully on the cloud (1-2 mins)
- Share the Loom link in your documentation

## Tech Stack 💻

- **Infrastructure**: Terraform
- **Orchestration**: Cloud-native (SageMaker/Vertex AI/Azure ML)
- **MLOps**: ZenML
- **Language**: Python

## Deliverables 📦

Submit a private GitHub repo (fork this repo and push your changes to a new private one). Add collaborators: `htahir1`, `stefannica`, and `AlexejPenner`.

Your repository should contain:

1. **Terraform Code**: Your updated `infrastructure/main.tf` used to provision the cloud stack using the official ZenML Terraform module.
2. **Pipeline Execution Proof**: Use the included `src/run.py` (already provided) as a smoke test and run it against your cloud stack successfully.
   - You may modify `src/run.py`, but you don't have to.
3. **Log Store Integration**: Terraform code that registers a ZenML `log_store` stack component and uses it in a ZenML stack.
4. **Documentation**: A short guide titled "How to migrate your ZenML pipeline to the cloud" that explains your solution end-to-end. Include:
   - A short explanation of what a **Log Store** is and why it matters
   - Where to find logs for a pipeline run / step in your chosen setup
   - A short **Architecture** section (keep it short — ~1 page max) covering:
     - components you deployed
     - trust boundaries and where secrets live
     - expected costs + one cost optimization idea
5. **Demo Video**: A link to your **5-minute Loom video** in the documentation.

## Evaluation Criteria 🔍

We are not looking for the most complex Terraform setup. We are looking for:

1. **Documentation Reading**: Did you use the official ZenML modules correctly?
2. **Debugging Skills**: Did you figure out cloud authentication and service connector setup?
3. **Customer Empathy**: Is your documentation and video clear, encouraging, and easy for a Data Scientist to understand?
4. **Observability**: Did you configure a log store and make it obvious where to find step logs?
5. **"It Works"**: Does the pipeline actually run on the cloud stack?

## AI Policy 🤖

AI use **is allowed**. If you use it, add a short **AI Diary** to your documentation with:

- What you asked
- What you copied
- What you changed

If you didn't use AI, just write: **"No AI used."**

## Time Management ⏱️

**Target time**: ~4 hours. If you get stuck on a specific cloud permission error (AWS IAM is tricky!) or run out of time:

- Stop coding
- Write down exactly what the error is, why you think it's happening, and how you would solve it given more time

We value the "Detective Work" just as much as the solution.

## Resources 📚

- [ZenML Terraform Modules Registry](https://registry.terraform.io/modules/zenml-io/zenml-stack)
- [Deploy a cloud stack with Terraform (ZenML docs)](https://docs.zenml.io/stacks/deployment/deploy-a-cloud-stack-with-terraform)
- [ZenML Service Connectors Guide](https://docs.zenml.io/stacks/service-connectors/auth-management)
- [ZenML Log Stores](https://docs.zenml.io/stacks/stack-components/log-stores)
- [ZenML Logging](https://docs.zenml.io/concepts/steps_and_pipelines/logging)
- [ZenML Terraform Provider](https://registry.terraform.io/providers/zenml-io/zenml/latest/docs)

---

**Good luck! We're excited to see how you guide our customers to success.** ✨