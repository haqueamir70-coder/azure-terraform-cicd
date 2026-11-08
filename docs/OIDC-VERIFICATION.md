# Azure OIDC verification evidence

**Verification date:** 8 November 2026  
**Repository:** `haqueamir70-coder/azure-terraform-cicd`  
**Branch:** `main`  
**Workflow run:** [Azure Terraform CI #31](../../actions/runs/42474695790)

## Verified results

The manually dispatched workflow completed successfully with all three jobs successful:

| Job | Result |
|---|---|
| Validate root example | Success |
| Validate dated lab example | Success |
| Optional authenticated plan | Success |

The authenticated job log confirms:

- Issuer: `https://token.actions.githubusercontent.com`
- Subject: `repo:haqueamir70-coder@253802285/azure-terraform-cicd@1331310763:environment:azure-plan`
- Audience: `api://AzureADTokenExchange`
- Azure CLI reported: `Azure CLI login succeeds by using OIDC.`
- Azure CLI reported the subscription was set successfully.
- `terraform init -backend=false` completed.
- `terraform plan -input=false -no-color` completed with **1 to add, 0 to change, 0 to destroy**. The proposed resource was `azurerm_resource_group.rg`, named `rg-github-cicd-demo`, in `East US`.

## Scope and limitations

This is evidence of a successful GitHub-to-Entra OIDC token exchange, Azure CLI sign-in, subscription selection and an authenticated Terraform plan command.

It is **not** evidence of an infrastructure deployment. No `terraform apply` was run.

The workflow initializes Terraform with `-backend=false`; therefore this plan did not use a configured remote Azure Storage state backend. Treat the one-resource plan as a backend-free demonstration plan, not as a safe deployment plan or a drift assessment against an existing managed environment.

Before any apply-capable workflow is introduced:

1. Configure an Azure Storage remote backend with restricted access, encryption, versioning/soft delete and state locking/lease behavior.
2. Bootstrap and verify the backend independently; do not point multiple workspaces or environments at the same state key.
3. Verify the federated app's least-privilege Azure RBAC permissions for both the state storage data plane and intended resource operations.
4. Review the complete plan from the remote-state-backed workflow and require a protected approval gate.
5. Keep apply manual and separate until the security and recovery controls are tested.

## Security work still open

- Identify and revoke the exact historical exposed service-principal credential after dependency review.
- Review Microsoft Entra service-principal sign-in logs and Azure Activity Logs for unexpected access.
- Verify repository secret scanning and push protection settings.
- Pin third-party GitHub Actions to reviewed immutable commit SHAs.


## Follow-up validation — existing resource group

After the owner created `rg-github-cicd-demo` manually, the root example was changed from an Azure resource-group resource to a data source. This prevents Terraform from proposing a duplicate resource-group creation.

The resulting push workflow [Azure Terraform CI #34](../../actions/runs/42478220728) completed successfully:
- Root Terraform formatting, initialization with backend disabled, and validation: success.
- Dated lab initialization and validation: success.
- Optional authenticated plan: skipped because this was a push event, not a manual dispatch.

This follow-up validates configuration syntax and confirms the normal CI path. It does **not** verify the resource-group data lookup against Azure; the authenticated plan must be manually dispatched to test that lookup. It also does not test the remote backend.
