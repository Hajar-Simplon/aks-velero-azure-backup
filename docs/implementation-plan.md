# Implementation Plan

## Phase 1 — Prepare and validate

1. Verify Azure CLI authentication and selected subscription.
2. Read the existing `hmezouarRG` resource group through a Terraform data
   source, without importing or managing it.
3. Choose an Azure region based on proximity, AKS availability, and quota.
4. Confirm that required resource providers are registered.
5. Confirm regional VM quota before creating AKS.
6. Record all design decisions before deployment.

## Phase 2 — Provision infrastructure

Use Terraform to reference the existing resource group as a data source and
create:

- AKS cluster with OIDC issuer and Workload Identity;
- Storage account;
- private Blob container named `velero`;
- user-assigned managed identity for Velero;
- least-privilege role assignment;
- federated identity credential for the Velero Kubernetes ServiceAccount.

Terraform state is stored in a dedicated Azure Blob backend rather than only
on an administrator workstation. The state container remains separate from
the Velero backup container.
Terraform must never declare or import the resource group as a managed resource.

## Phase 3 — Install Velero

1. Install a Velero CLI version compatible with the chosen Azure plugin.
2. Install the Velero server in AKS.
3. Configure Azure Blob Storage as the BackupStorageLocation.
4. Configure the `velero` ServiceAccount for Workload Identity.
5. Verify that the backup location reports `Available`.

## Phase 4 — Backup and restore demonstration

1. Deploy the Nginx Deployment, Service, and ConfigMap.
2. Verify the resources before backup.
3. Create a manual backup of the namespace.
4. Confirm status `Completed` with zero errors.
5. Confirm that backup blobs exist in the Azure container.
6. Delete the namespace.
7. Confirm that the namespace no longer exists.
8. Restore from the Velero backup.
9. Verify all application resources and ConfigMap values.

## Phase 5 — Documentation and evidence

Keep only evidence relevant to the brief:

1. AKS nodes in `Ready` state.
2. Azure Blob container exists.
3. Velero BackupStorageLocation is `Available`.
4. Nginx resources exist before backup.
5. Velero backup is `Completed`.
6. Backup blobs are visible in the container.
7. Namespace is absent after deletion.
8. Velero restore is `Completed`.
9. Required resources exist after restoration.

Never capture access keys, SAS tokens, client secrets, bearer tokens, or
pre-signed download URLs.
