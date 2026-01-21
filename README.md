End-to-End CI/CD Deployment to AWS EC2 (OIDC + Terraform + SSM)
Overview

This project demonstrates a complete, production-oriented CI/CD system for deploying a containerized FastAPI application to AWS EC2 without using SSH or static cloud credentials.

The focus of this project is not on tools alone, but on operational correctness, security, and real-world failure handling. Every component reflects decisions commonly made in production environments.

What This Project Demonstrates

Secure CI/CD using GitHub Actions with AWS OIDC (no access keys)

Infrastructure as Code using Terraform

Container image lifecycle with Docker and Amazon ECR

SSH-free EC2 management using AWS Systems Manager (SSM)

Decoupled infrastructure and application lifecycles

Safe, transferable architecture suitable for public repositories

High-Level Architecture

Flow (simplified):

Code is pushed to GitHub

GitHub Actions builds a Docker image

Image is pushed to Amazon ECR

AWS SSM deploys the new image to EC2

EC2 runs the containerized application

Infrastructure provisioning is handled separately via Terraform.

flowchart LR
    Dev[Developer<br/>git push]

    Repo[GitHub Repository]
    CI[GitHub Actions<br/>CI/CD Pipeline]

    IAM[AWS IAM<br/>OIDC Trust]
    ECR[Amazon ECR<br/>Container Registry]
    SSM[AWS Systems Manager<br/>SSM]

    EC2[EC2 Instance<br/>IAM Instance Profile]
    App[FastAPI Container<br/>Port 8000<br/>/health]

    TF[Terraform<br/>Infrastructure as Code]

    Dev -->|Code push| Repo
    Repo -->|Trigger on push| CI

    CI -->|OIDC AssumeRole<br/>(No static credentials)| IAM
    CI -->|Push Docker image| ECR
    CI -->|Send deployment commands| SSM

    EC2 -->|Pull image| ECR
    SSM -->|Run shell commands<br/>(No SSH)| EC2
    EC2 -->|docker run| App

    TF -->|Provision infrastructure| IAM
    TF -->|Provision infrastructure| EC2


Why This Architecture

EC2 instead of EKS: Cost-effective, simpler runtime for this use case

OIDC instead of access keys: Eliminates secret storage in CI

SSM instead of SSH: Centralized, auditable, and secure instance control

Terraform instead of manual setup: Reproducible infrastructure

These choices prioritize security, clarity, and operational maturity.

Repository Structure
.
├── app/          # FastAPI application and Dockerfile
├── terraform/    # Terraform infrastructure definitions
├── scripts/      # Operational SSM command references
├── docs/         # Architecture decisions and learning notes
├── diagrams/     # Architecture diagrams
└── .github/      # CI/CD workflow examples (disabled)

CI/CD Workflow (Example)

This repository includes a sanitized, disabled example of the GitHub Actions workflow used for deployment.

The workflow demonstrates:

OIDC-based authentication to AWS

Docker image build and push to ECR

Deployment to EC2 via SSM

The workflow is intentionally disabled to prevent unintended execution against real cloud resources.

Key Learnings

CI/CD pipelines are control planes, not scripts

IAM permissions and runtime authentication are separate concerns

Infrastructure and application deployments should be decoupled

Most failures occur at integration boundaries, not in individual tools

Transferability

This project is designed to remain reviewable even after cloud resources are destroyed:

No credentials are stored

Infrastructure is reproducible

CI/CD logic is documented but safe

The repository stands independently of AWS free-tier availability

🔐 Security Model

This project was designed with security as a first-class concern rather than an afterthought.

Key security characteristics include:

OIDC-based authentication between GitHub Actions and AWS (no static access keys)

IAM role-based permissions with least-privilege policies

SSH-free EC2 operations, using AWS Systems Manager (SSM) as the control plane

No credentials, secrets, or account-specific identifiers stored in the repository

CI/CD workflows are provided in a disabled example form to prevent unintended execution in public contexts

These choices reflect real-world production security practices.

🛠 Debugging & Failure Handling

A core objective of this project was to understand how distributed systems fail and how those failures are diagnosed in practice.

During implementation, multiple real-world issues were encountered and resolved, including:

Distinguishing IAM permissions from runtime authentication when pulling images from ECR

Debugging Docker authentication failures on EC2 despite valid IAM roles

Resolving image tag mismatches between CI builds and runtime pulls

Understanding and handling the asynchronous execution model of AWS SSM commands

Identifying local shell and tooling issues versus actual cloud configuration problems

These experiences informed the final architecture and deployment strategy.

✅ Deployment Verification

Deployments are validated explicitly rather than assumed to be successful.

Verification steps include:

Health endpoint exposure (/health) in the application

Container lifecycle checks after deployment (pull, stop, remove, run)

Manual and scripted validation via SSM-executed commands on the EC2 instance

This ensures that CI/CD success reflects actual runtime correctness, not just pipeline completion.


🚫 Why Kubernetes Is Not Used Here

This project intentionally does not use Kubernetes for the runtime layer.

Kubernetes was evaluated and used separately to validate reliability concepts such as readiness probes, rolling updates, and canary deployments. However, for this project, EC2 + Docker was selected as the runtime for the following reasons:

Cost efficiency: Managed Kubernetes (EKS) introduces ongoing control-plane costs that are unnecessary for a single-service deployment.

Architectural clarity: This project focuses on CI/CD security, IAM boundaries, and deployment mechanics rather than container orchestration complexity.

Operational realism: Many production systems—especially internal tools and early-stage services—run successfully on EC2 with containerized workloads and automated deployment pipelines.

Separation of concerns: Kubernetes-specific reliability mechanisms were validated independently to avoid conflating orchestration learning with CI/CD and IAM design.

The absence of Kubernetes here is a deliberate architectural decision, not a knowledge gap.

⚠️ Known Limitations & Trade-offs

This architecture intentionally accepts certain limitations in exchange for simplicity, cost control, and clarity.

Key trade-offs include:

No automated health-gated deployments: Unlike Kubernetes probes, deployment success is validated manually or via scripted checks.

Manual rollback: Rollbacks require redeploying a previous image from ECR rather than automatic traffic shifting.

Single-instance runtime: The EC2 instance represents a single failure domain and does not provide horizontal scaling.

No load balancer: The application is exposed directly via EC2 for demonstration purposes.

Basic observability: Logging and monitoring are limited to container output and AWS-native tooling.

These limitations are documented intentionally and reflect conscious design choices rather than omissions.

### Failure Impact & Recovery

This system intentionally operates with a single EC2 instance and no load balancer.
As a result, any failed deployment or instance-level failure impacts 100% of traffic.
There is no automated failover.

Recovery is performed manually by redeploying a previously known-good image from Amazon ECR via AWS Systems Manager.
This trade-off was accepted to minimize cost and complexity while preserving clear, auditable recovery paths.

Operational Invariants

The following invariants must always hold true for this system to function correctly.
Violating these assumptions will result in undefined behavior or service disruption.

The EC2 instance must always have an IAM instance profile attached

The application cannot pull images or be managed without IAM-based access.

Docker must be installed and running before any deployment commands execute.

Application deployments must not be performed via Terraform

Terraform manages infrastructure lifecycle only.

CI/CD must authenticate via OIDC

Static credentials or long-lived access keys are explicitly unsupported.

Only one EC2 instance is supported by this architecture.

Scaling assumptions are intentionally constrained (see limitations).


Operator Responsibilities & Guardrails

This system assumes a single responsible operator.

The operator is expected to:

Use CI/CD pipelines for application updates.

Use Terraform only for infrastructure changes.

Validate deployments explicitly via:

Application health endpoints

Runtime container state checks

Perform rollbacks by redeploying a known-good image from ECR.

The operator must not:

SSH into the EC2 instance.

Manually edit runtime configuration on the host.

Run ad-hoc Docker commands outside of documented deployment flows.

Modify IAM policies without understanding downstream impact.

These guardrails exist to preserve reproducibility, security, and debuggability.

Failure Impact & Recovery

This architecture intentionally uses a single EC2 instance.

Failure impact:

A failed deployment impacts 100% of traffic.

Instance failure results in full service outage until recovery.

There is no automatic traffic shifting or redundancy.

Recovery strategy:

Roll back by redeploying a previous image from ECR.

Restart the container via SSM-executed commands.

Recreate infrastructure via Terraform if required.

These trade-offs are accepted intentionally to prioritize cost control, simplicity, and clarity.

Explicit Non-Goals & Future Direction

This project intentionally does not attempt to solve:

High availability

Horizontal scaling

Automatic traffic shifting

Zero-downtime deployments on EC2

If these requirements emerge, the correct next steps would include:

Introducing a load balancer and multiple instances or

Migrating the runtime to Kubernetes

Incremental patches to the current architecture are not recommended for these use cases.


Human Factors & Operational Reality

Most failures encountered during this project occurred not due to tooling defects, but due to:

Misaligned assumptions between systems

Authentication vs authorization misunderstandings

Asynchronous execution expectations

Human interpretation errors

This project treats operational clarity as a first-class concern, equal to correctness and security.

🧠 Key Terraform & AWS Lessons Learned

This project surfaced several real-world infrastructure and cloud platform insights:

Infrastructure state matters more than configuration files
Terraform behavior is governed by state, not intent. Drift between AWS resources and Terraform state leads to unexpected outcomes if not managed carefully.

IAM permissions ≠ runtime authentication
Granting an EC2 instance permission to access ECR does not automatically authenticate Docker. Explicit ECR login is required at runtime.

CI roles and runtime roles are separate trust domains
GitHub Actions IAM permissions are completely independent of EC2 instance permissions. Each role must be scoped and reasoned about separately.

User data execution is not idempotent
EC2 user data runs only at instance creation unless explicitly configured otherwise (user_data_replace_on_change).

Asynchronous systems require explicit verification
AWS SSM command execution is asynchronous. Success must be verified through invocation status and output, not assumed.

These lessons influenced the final architecture and deployment flow.

