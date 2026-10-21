# Security Policy

This repository is a learning project for Terraform delivery workflows. Do not connect it to production subscriptions without reviewing permissions, workflow triggers, and approval model.

## Required safeguards
- Prefer OIDC/workload identity federation to long-lived cloud secrets.
- Grant deployment identities only the permissions required for the target scope.
- Protect the default branch and production environments.
- Require review of Terraform plans before apply.
- Do not upload Terraform state or secret-bearing plan files as public artifacts.
- Store credentials in approved secret stores; never place them in YAML or logs.
- Pin and review third-party Actions and provider versions.
- Run format, validation, lint, and IaC security checks.
- Review scanner findings and document accepted exceptions.

## Reporting
Use GitHub's private security reporting feature if enabled. Do not include live secrets or sensitive infrastructure details in public issues.
