# Azure Remote State — Bootstrap and Migration Runbook

## Current environment

The following resources were created manually by the repository owner and are **not yet configured as Terraform's backend**:

| Item | Value |
|---|---|
| Resource group | `rg-github-cicd-demo` |
| Storage account | `storagegithub43` |
| Blob container | `github-container` |
| Container access | Private |
| State blob key | `terraform.tfstate` (proposed) |
| Authentication target | GitHub Actions OIDC app registration `twischat_new` |

Do not put subscription IDs, tenant IDs, client secrets, storage account keys, SAS tokens, state files or plan files in this repository.

## Access prerequisite — currently blocked

The GitHub OIDC application needs the **Storage Blob Data Contributor** data-plane role scoped to the `storagegithub43` storage account (or a narrower supported container scope). The signed-in human Contributor role does not automatically grant this data-plane permission to the app registration, and Contributor generally cannot create role assignments.

A Subscription Owner or User Access Administrator must grant the role to the service principal represented by the `twischat_new` app registration. Do not work around this by committing an account key or SAS token.

The existing app registration currently has a GitHub federated credential for repository `haqueamir70-coder/azure-terraform-cicd`, environment `azure-plan`. Keep the OIDC subject restricted to that exact repository and environment.

## Backend configuration to add after RBAC is granted

Add this block to the root Terraform configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-github-cicd-demo"
    storage_account_name = "storagegithub43"
    container_name       = "github-container"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
```

The AzureRM backend is initialized separately from the provider. Keep backend authentication on OIDC and Microsoft Entra data-plane auth; do not use storage account keys.

## GitHub Actions requirements

The authenticated job must retain:

- GitHub environment: `azure-plan`
- Job permission: `id-token: write`
- `ARM_USE_OIDC: true`
- `ARM_USE_AZUREAD: true`
- `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` from the environment secrets
- An `azure/login@v2` step using the same OIDC identity

After adding the backend block, replace `terraform init -backend=false` with a normal `terraform init -input=false`. Do this only after the data-plane role has been granted and verified. The plan job must remain manual and plan-only; do not add `terraform apply`.

## Safe migration sequence

1. Confirm the storage account and private container exist in the intended subscription.
2. Enable blob versioning and blob/container soft delete; review secure transfer and public access settings.
3. Have an authorized administrator grant Storage Blob Data Contributor to the OIDC app at the storage account scope.
4. Verify the app can list/read/write blobs and acquire/release leases through the GitHub OIDC job.
5. Add the backend block and initialize the backend.
6. If a local state exists, inspect it and migrate only with an explicit `terraform init -migrate-state` decision. Never overwrite an existing remote state blindly.
7. Run a remote-state-backed plan and inspect every proposed action.
8. Keep apply disabled until state recovery, least-privilege permissions and an explicit approval process are verified.

## Current verified boundary

- GitHub-to-Entra OIDC login succeeded in workflow run #31.
- A backend-free authenticated plan succeeded.
- The current root Terraform example reads the manually created resource group as a data source; it does not attempt to recreate it.
- **Remote backend access has not been tested** because the OIDC app does not yet have the required Storage Blob Data Contributor role.
- No Terraform apply or infrastructure deployment was performed by this runbook.
