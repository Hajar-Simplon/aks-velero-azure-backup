# AKS Backup and Restore with Velero and Azure Blob Storage

This project demonstrates how to back up and restore Kubernetes resources on
Azure Kubernetes Service (AKS) with Velero. Backup objects are stored in an
Azure Blob Storage container.

## Target architecture

```text
AKS cluster
|-- nginx-demo namespace
|   |-- Deployment
|   |-- Service
|   `-- ConfigMap
|
`-- velero namespace
    `-- Velero pod
        |
        | Microsoft Entra Workload Identity
        v
Azure Storage account
`-- Blob container: velero
    `-- Velero backup objects
```

## Mandatory objectives

- [x] Validate the Azure account, subscription context, region, and quota.
- [x] Create an AKS cluster with OIDC and Workload Identity enabled.
- [x] Create an Azure Storage account and a private Blob container named
      `velero`.
- [x] Grant Velero least-privilege access to the container.
- [x] Install Velero with the Microsoft Azure plugin.
- [x] Deploy the Nginx test resources.
- [x] Create a manual Velero backup.
- [x] Confirm that backup blobs exist in Azure Storage.
- [x] Delete the test namespace and confirm that it no longer exists.
- [x] Restore the namespace from the backup.
- [x] Verify the restored Deployment, pods, Service, and ConfigMap.
- [ ] Add the final deletion and restoration screenshots.

## Preferred implementation

- Infrastructure as Code: Terraform.
- Authentication: Microsoft Entra Workload Identity rather than storage keys.
- AKS type: Standard, dev/test sized for this two-day lab.
- Pod networking: Azure CNI Overlay.
- Storage: Standard general-purpose v2 account with a private Blob container.
- Initial redundancy: LRS for cost-controlled lab use.
- Secrets: never committed to Git.

## Bonus objectives

- [ ] Restrict Storage access to the AKS network and approved Simplon network.
- [ ] Enable Blob soft delete.
- [ ] Use cross-region replication such as GRS or GZRS.
- [ ] Configure customer-managed encryption keys with Azure Key Vault.

## Repository structure

```text
.
|-- docs/          Procedure, decisions, results, and final report
|-- manifests/     Nginx demonstration resources
|-- screenshots/   Required evidence only
|-- terraform/     AKS, identity, RBAC, and Storage infrastructure
|-- .gitignore
`-- README.md
```

## Safety

This repository must never contain Azure access keys, client secrets, SAS
tokens, kubeconfig files, Terraform state, or downloaded Velero credentials.

## Demonstrated result

The manual backup `nginx-backup` completed with all 54 discovered items and no
errors or warnings. After the `nginx-demo` namespace was deleted, the
`nginx-restore` operation completed and restored all 15 selected items. The
Deployment subsequently reached `2/2` available replicas, with both Nginx pods
in the `Running` state. See [the restoration procedure](docs/07-restore.md).
