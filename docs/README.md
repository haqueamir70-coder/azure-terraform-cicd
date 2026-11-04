# Azure Terraform CI/CD with OIDC and gated plans — Architecture & Interview Guide

The pipeline validates Terraform on pull requests and supports an optional protected, OIDC-authenticated plan. Apply is deliberately not automatic. Rotate any credential previously exposed in Git history.

## Architecture diagram

```mermaid
flowchart TD
  A[Developer push / pull request] --> B[Checkout]
  B --> C[Terraform fmt -check]
  C --> D[Terraform init -backend=false]
  D --> E[Terraform validate]
  E --> F[Static security scan]
  F --> G{Manual plan requested?}
  G -- No --> H[Validation result]
  G -- Yes --> I[Protected GitHub Environment]
  I --> J[GitHub OIDC token]
  J --> K[Microsoft Entra federated credential]
  K --> L[AzureRM plan]
  L --> M[Review plan; no automatic apply]
```

## Interview questions

1. 1. Explain the end-to-end Terraform CI workflow in this repository.
2. 2. Why is terraform init -backend=false appropriate for credential-free validation?
3. 3. How does GitHub Actions OIDC authenticate to Azure?
4. 4. What trust conditions should be configured on the federated credential?
5. 5. Why should production plans use a protected GitHub Environment?
6. 6. Why is automatic terraform apply -auto-approve dangerous?
7. 7. How would you handle remote state and state locking in production?
8. 8. How do you prevent secrets from appearing in logs or Git history?
9. 9. What steps are required after a service-principal secret is exposed?
10. 10. How would you add policy checks and approval gates before apply?

## Interview preparation note
Be ready to explain the design decision, security boundary, failure mode, operational signal and validation evidence for each answer. Clearly separate implemented code, CI-validated configuration, cloud-deployed resources and future roadmap items.


## Interview questions — suggested answers

### 1. Answer

The workflow validates formatting, initializes without a backend for credential-free validation, validates configuration and can run security checks. A protected manual path can request an OIDC-authenticated plan; it does not auto-apply.

### 2. Answer

init -backend=false downloads providers and prepares local validation without connecting to a configured remote backend. It is suitable for syntax/validation jobs that need no state access.

### 3. Answer

GitHub Actions requests an OIDC token; Microsoft Entra validates the federated issuer, subject and audience, then issues short-lived Azure tokens for the app identity.

### 4. Answer

Restrict issuer to GitHub, audience to Azure token exchange, and subject to the exact repository plus branch or protected environment. Avoid wildcard trust where possible.

### 5. Answer

A protected environment can require reviewers, scope secrets/variables and separate production authorization from ordinary pull-request validation.

### 6. Answer

Auto-apply can modify or destroy infrastructure without a human reviewing the actual plan. Production changes should use plan artifacts, approval and a controlled apply stage.

### 7. Answer

Use a dedicated Storage Account/container with encryption, private access, state locking/lease controls, versioning and narrowly scoped data-plane permissions.

### 8. Answer

Use secret scanning and push protection, OIDC instead of client secrets, masked environment variables, restricted logs, and rotate/revoke any credential exposed in history.

### 9. Answer

Immediately revoke the exposed credential, inspect sign-in and Activity Logs, check role assignments and resource changes, replace consumers with OIDC, then consider history cleanup after coordination.

### 10. Answer

Add Checkov/TFLint, plan JSON policy checks, artifact retention, environment approvals, drift detection and a separate apply workflow with explicit authorization.