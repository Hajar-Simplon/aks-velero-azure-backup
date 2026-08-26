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
- [ ] Deploy the Nginx test resources.
- [ ] Create a manual Velero backup.
- [ ] Confirm that backup blobs exist in Azure Storage.
- [ ] Delete the test namespace.
- [ ] Restore the namespace from the backup.
- [ ] Verify the restored Deployment, pods, Service, and ConfigMap.
- [ ] Complete the final documentation and screenshot evidence.

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
