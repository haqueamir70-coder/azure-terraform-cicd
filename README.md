<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0B1020,45:1D4ED8,100:38BDF8&height=220&section=header&text=Azure%20Terraform%20Delivery%20Engine&fontSize=34&fontColor=ffffff&animation=fadeIn" width="100%" alt="Azure Terraform Delivery Engine"/>

### Infrastructure as Code · Secure CI · Human-approved change management

[![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://docs.github.com/actions)
[![Security](https://img.shields.io/badge/Identity-OIDC-0F766E?style=for-the-badge)](https://learn.microsoft.com/azure/developer/github/connect-from-azure)

**A secure delivery workflow for Terraform-managed Azure infrastructure — from pull-request validation to an explicitly reviewed plan.**

[Architecture](#-delivery-architecture) · [Quick start](#-quick-start) · [Security](#-security-model) · [Runbooks & interview guide](docs/README.md)

</div>

> [!IMPORTANT]
> **Safety boundary:** the current workflow does not perform an automatic Terraform apply. The default validation path does not need Azure credentials. The optional Azure plan requires a separately configured GitHub environment and OIDC federation. No production deployment is claimed.

## The engineering problem

Infrastructure pipelines can turn a harmless code change into a costly or destructive cloud operation. This project demonstrates how to separate **untrusted code validation**, **cloud-authenticated planning**, and **human authorization**.

## Delivery architecture

```mermaid
flowchart LR
  Dev[Engineer] --> PR[Pull request]
  PR --> CI[GitHub Actions]
  CI --> Fmt[Terraform fmt]
  Fmt --> Init[Init without backend]
  Init --> Val[Terraform validate]
  Val --> Review[Code review]
  Review --> Gate{Need Azure plan?}
  Gate -->|Approved request| OIDC[GitHub OIDC]
  OIDC --> Plan[Terraform plan]
  Plan --> Human[Human review]
  Human -. no automatic apply .-> Stop[Operator-controlled next step]
```

## What this repository demonstrates

- Terraform configuration checks in GitHub Actions.
- Backend-free initialization for credential-free validation jobs.
- A separate optional OIDC-authenticated planning path.
- Explicit separation between pull-request validation and cloud permissions.
- A human review point before any infrastructure change is applied.

## Technology stack

| Layer | Technology | Purpose |
|---|---|---|
| Infrastructure | Terraform, AzureRM | Declare Azure resources |
| Source control | Git, GitHub | Version and review infrastructure changes |
| Automation | GitHub Actions | Repeatable quality gates |
| Identity | GitHub OIDC, Microsoft Entra ID | Short-lived federated identity |
| Governance | Protected environments, reviewer approval | Control cloud-authenticated operations |

## Quick start

### Prerequisites

- Terraform CLI compatible with the repository's version constraints.
- Git.
- Azure CLI only if you intend to run an authenticated plan.
- A non-production Azure subscription for any optional cloud operation.

### Validate locally

Run from the Terraform root module directory:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Inspect the workflow definitions in `.github/workflows/` before relying on any CI behavior. Run `terraform plan` only after configuring the correct backend, identity, subscription and input values.

## Security model

- **No embedded credentials:** never put service-principal secrets in YAML, scripts or committed variable files.
- **Federated identity:** prefer OIDC over long-lived client secrets.
- **Least privilege:** scope the Azure role to the exact resources and operations needed.
- **Protected environment:** require reviewer approval for cloud-authenticated planning where appropriate.
- **State protection:** remote state must have restricted access, encryption, versioning and locking.
- **No automatic apply:** this repository intentionally keeps apply outside the default CI path.

> [!CAUTION]
> A historical workflow revision contained an exposed service-principal credential and an automatic apply step. The current workflow removes both patterns, but Git history may still contain the old credential. **Revoke and rotate that credential immediately if this has not already been done**, then review Azure sign-in and activity logs. Removing a secret from the latest file does not erase it from Git history.

## Repository navigation

| Path | Purpose |
|---|---|
| `.github/workflows/` | CI and optional OIDC plan workflows |
| `docs/README.md` | Architecture, interview questions and answers |
| `docs/ZERO-TO-HERO.md` | End-to-end learning guide |
| `docs/ADVANCED-INTERVIEW-BANK.md` | Advanced scenario-based Q&A |

## Operational checklist

- [ ] Review Terraform provider and action versions.
- [ ] Configure backend and state access separately from validation.
- [ ] Configure GitHub OIDC trust for the exact repository/environment.
- [ ] Restrict the Azure role to required actions.
- [ ] Review the complete plan and estimated cost.
- [ ] Obtain approval before any apply.
- [ ] Record the change and rollback procedure.

## Validation evidence

A successful `fmt`, `init` or `validate` step proves configuration checks completed; it does **not** prove Azure resources were deployed. Check the repository's [Actions history](../../actions) for current workflow evidence.

## Further reading

- [Microsoft: Connect GitHub Actions to Azure using OIDC](https://learn.microsoft.com/azure/developer/github/connect-from-azure)
- [Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli)
- [GitHub Actions security hardening](https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)

## Maintainer

**MD Amirul Haque** · [GitHub](https://github.com/haqueamir70-coder) · [LinkedIn](https://www.linkedin.com/in/md-amirul-haque/)

<sub>Build safely. Review every plan. Keep cloud identity short-lived.</sub>
