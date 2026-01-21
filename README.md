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




