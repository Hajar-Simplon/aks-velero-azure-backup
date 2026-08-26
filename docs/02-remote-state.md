# Remote Terraform State

## Objective

Terraform state is stored in Azure Blob Storage rather than relying on a single
administrator workstation. This provides a persistent source of infrastructure
state and supports state locking during Terraform operations.

## Architecture

```text
Azure Storage account: tfstatehmez0c93dc
`-- private container: tfstate
    `-- aks-velero.tfstate
```

The backend is intentionally separate from the Blob container used by Velero:

- the `tfstate` container records infrastructure managed by Terraform;
- the `velero` container stores Kubernetes backup objects.

## Security controls

- Blob public access is disabled.
- Shared-key authentication is disabled.
- Microsoft Entra authentication is enabled for Terraform backend access.
- `Storage Blob Data Contributor` is scoped to the state Storage account.
- TLS 1.2 and HTTPS-only transport are enforced.
- Standard LRS replication provides a cost-controlled baseline for the lab.

The state file and saved Terraform plans are excluded from version control.
State contents are not included in screenshots or project documentation.

## Terraform backend

The `azurerm` backend uses the following logical configuration:

| Setting | Value |
|---|---|
| Resource group | Existing `hmezouarRG` |
| Storage account | `tfstatehmez0c93dc` |
| Container | `tfstate` |
| State key | `aks-velero.tfstate` |
| Authentication | Microsoft Entra ID |

Backend initialization must succeed before infrastructure is deployed.
