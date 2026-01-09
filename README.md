# ZenML Solutions Challenge — The Cloud Migration (4h)

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

This includes:
- **Artifact Store** (S3/GCS/Azure Blob)
- **Container Registry** (ECR/GCR/ACR)
- **Orchestrator** (SageMaker/Vertex AI/Azure ML)

**Why this stack?** This is the most common migration path for customers moving from local development to production.

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
3. **Documentation**: A short guide titled "How to migrate your ZenML pipeline to the cloud" that explains your solution end-to-end.
4. **Demo Video**: A link to your **5-minute Loom video** in the documentation.

## Evaluation Criteria 🔍

We are not looking for the most complex Terraform setup. We are looking for:

1. **Documentation Reading**: Did you use the official ZenML modules correctly?
2. **Debugging Skills**: Did you figure out cloud authentication and service connector setup?
3. **Customer Empathy**: Is your documentation and video clear, encouraging, and easy for a Data Scientist to understand?
4. **"It Works"**: Does the pipeline actually run on the cloud stack?

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

---

**Good luck! We're excited to see how you guide our customers to success.** ✨