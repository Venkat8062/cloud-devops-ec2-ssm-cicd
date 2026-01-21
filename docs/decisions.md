# Architecture Decisions & Engineering Rationale

This document captures the **key technical decisions**, tradeoffs, and lessons learned while building this project.
It is intentionally candid and reflects real-world engineering constraints rather than idealized designs.

The goal was not to maximize tooling complexity, but to build a **correct, secure, and operable system**.

---

## 1. Why EC2 Instead of Kubernetes / EKS

Kubernetes was intentionally **not** used in this project.

### Rationale
- Managed Kubernetes (EKS) introduces:
  - Additional cost
  - Operational complexity
  - Control plane management overhead
- For a single-container, single-service application, EKS would not provide proportional value.
- EC2 + Docker provides:
  - Full control over runtime behavior
  - Simpler failure domains
  - Clearer debugging paths

Kubernetes reliability concepts (health probes, rolling updates, canary deployments) were explored in a **separate, dedicated Kubernetes project** to avoid mixing concerns.

---

## 2. Why Terraform for Infrastructure Provisioning

Infrastructure was provisioned using **Terraform** instead of manual configuration or ad-hoc scripts.

### Rationale
- Infrastructure should be:
  - Reproducible
  - Reviewable
  - Destroyable and recreatable
- Terraform provides:
  - Declarative infrastructure definitions
  - Clear dependency graphs
  - Separation between infrastructure lifecycle and application lifecycle

Terraform is used **only** for infrastructure creation, not for application deployment.

---

## 3. Why CI/CD Is Decoupled from Terraform

Application deployment is intentionally **not** handled by Terraform.

### Rationale
- Terraform manages infrastructure state, not application runtime state.
- Tying application updates to infrastructure provisioning:
  - Increases blast radius
  - Slows deployments
  - Complicates rollbacks

Instead:
- Terraform provisions stable infrastructure
- CI/CD updates application artifacts independently

This mirrors real-world production practices.

---

## 4. Why GitHub Actions with OIDC

CI/CD authentication uses **OIDC (OpenID Connect)** instead of static AWS access keys.

### Rationale
- Eliminates long-lived credentials
- Reduces secret management overhead
- Credentials are:
  - Short-lived
  - Automatically rotated
  - Scoped to repository and workflow context

This significantly reduces the risk of credential leakage.

---

## 5. Why AWS Systems Manager (SSM) Instead of SSH

The EC2 instance is managed exclusively via **AWS Systems Manager (SSM)**.

### Rationale
- SSH access:
  - Requires key management
  - Expands attack surface
  - Is difficult to audit centrally
- SSM provides:
  - IAM-based access control
  - Centralized command execution
  - Auditable command history
  - No inbound ports required

This enables **SSH-free operations**, which is a common enterprise security requirement.

---

## 6. Key Debugging & Failure Scenarios Encountered

This project intentionally embraced real-world failures.

### Examples:
- **ECR authentication failures** despite valid IAM roles
  - Learned distinction between IAM permissions and Docker runtime authentication
- **Image tag mismatches**
  - CI pushed images with commit SHA tags while EC2 attempted to pull `latest`
- **SSM execution confusion**
  - Learned that SSM commands are asynchronous and require invocation tracking
- **Local tooling issues**
  - Pager behavior, shell suspension, and CLI output misinterpretation

Each failure contributed directly to a stronger mental model of distributed systems.

---

## 7. Deployment Verification Philosophy

Deployments are not considered successful based on CI completion alone.

### Verification steps include:
- Explicit container lifecycle management:
  - Pull
  - Stop
  - Remove
  - Run
- Application-level health checks (`/health`)
- Runtime validation via SSM-executed commands

This ensures **actual runtime correctness**, not just pipeline success.

---

## 8. Public Repository & Security Considerations

This repository is intentionally designed to be public-safe.

Measures taken:
- No credentials or secrets stored
- Terraform state files excluded
- Environment-specific values parameterized
- CI/CD workflow included in disabled example form

The repository demonstrates **how the system works**, without allowing unintended execution.

---

## 9. Final Reflection

This project was not built to follow a tutorial.
It was built to understand:
- How systems fail
- How security boundaries are enforced
- How infrastructure and applications interact
- How real-world CI/CD differs from examples

The primary outcome is not a running service, but **operational understanding**.
