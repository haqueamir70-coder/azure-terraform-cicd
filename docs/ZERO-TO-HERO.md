# Zero-to-Hero Project Guide — Azure Terraform CI/CD with GitHub Actions

## 1. Business scenario
Infrastructure changes made manually are hard to audit and reproduce. Teams need pull-request validation, security checks, authenticated plans, approvals and a controlled apply path without storing long-lived Azure secrets in GitHub.

## 2. Target outcome
Automate quality gates and Terraform planning, use GitHub OIDC to obtain short-lived Azure credentials, protect production operations with environments/reviewers, and keep apply explicit.

## 3. Pipeline walkthrough
Developer PR → checkout → fmt → init without backend for static validation → validate → lint/security scan → review findings → protected environment → OIDC token exchange with Entra → Azure plan → human review → separately authorized apply (if configured).

## 4. Tool-by-tool
| Tool | What it does | Why it is used |
|---|---|---|
| GitHub Actions | Workflow orchestration | PR triggers, jobs, artifacts, approvals |
| Terraform CLI | IaC lifecycle | fmt, init, validate, plan, apply |
| AzureRM provider | Azure resource API | Provider pinning and lock file |
| Microsoft Entra ID | Federated identity issuer | Validates GitHub OIDC claims |
| GitHub OIDC | Short-lived workload identity token | Avoids static client secrets |
| Azure RBAC | Azure authorization | Scope role to required resources/actions |
| GitHub Environments | Deployment protection | Reviewers and environment-specific controls |
| Checkov | Terraform security scanning | Catch misconfiguration before deployment |
| TFLint | Terraform/provider lint | Detect configuration/provider issues |
| Remote state backend | Shared Terraform state | Collaboration, locking and recovery |

## 5. Workflow skeleton
```yaml
name: terraform-ci
on:
  pull_request:
  push:
    branches: [main]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check -recursive
      - run: terraform init -backend=false
      - run: terraform validate
```
This is a teaching skeleton; match action versions, working directory, scan steps and auth conditions to the actual repository workflow.

## 6. Commands
```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```
Never upload state or unredacted plan files as public artifacts.

## 7. Scenario-based Q&A
**Q1. Why use OIDC instead of an Azure client secret?**  
A: OIDC exchanges a signed GitHub identity token for short-lived Azure credentials. There is no long-lived secret to rotate, but trust must be tightly scoped by issuer, audience and subject (repository/ref/environment).

**Q2. OIDC login succeeds but Terraform receives authorization errors.**  
A: Authentication and authorization are separate. Verify the federated credential claims, tenant/subscription context, service principal or managed identity role assignments, scope and whether the action requires control-plane or data-plane permissions.

**Q3. Why run init with backend=false in PR validation?**  
A: It downloads provider plugins and supports validation without accessing remote state. It is not sufficient for a real plan that needs state.

**Q4. Why must plan and apply be separate?**  
A: The plan is a proposed change set. A reviewer must inspect deletes/replacements and context before applying. Use saved plan artifacts securely and ensure apply consumes the reviewed plan.

**Q5. A credential was committed to Git history. What do you do?**  
A: Revoke/rotate immediately, review Entra sign-in and Azure Activity Logs, inspect role assignments and resource changes, replace use with OIDC, then coordinate history cleanup. Deleting the file alone does not invalidate a leaked credential.

## 8. Troubleshooting
Wrong workflow trigger/branch → inspect event and permissions; OIDC failure → inspect subject/audience/issuer; Azure forbidden → inspect RBAC scope; provider mismatch → lock file/provider constraints; backend lock → inspect lease and concurrent runs, never force-unlock without confirming owner.

## 9. Security/reliability/cost
Least privilege, read-only PR validation, protected production environment, secret scanning, restricted artifacts, state encryption/versioning, concurrency controls and explicit destroy safeguards.

## 10. Learning path
Git/GitHub basics → YAML workflow anatomy → Terraform lifecycle → Azure service principal and OIDC claims → Entra federated credentials → RBAC → remote state → plan review → protected deployment.

## 11. Scope honesty
This repository uses a validation and protected plan pattern; it does not imply automatic production apply. Report exact workflow evidence and rotate any credential previously exposed in history.
