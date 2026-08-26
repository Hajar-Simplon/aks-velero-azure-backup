# Terraform

This directory contains the AKS, Azure Storage, managed identity, federated
credential, and RBAC configuration.

Do not run `terraform apply` until the generated plan has been reviewed.

## Protected resource group

The existing `hmezouarRG` resource group is referenced with an
`azurerm_resource_group` data source and `var.resource_group_name`. Never define,
import, rename, or delete the resource group through this project. Resources
created inside it remain separate project resources.

## Files

- `versions.tf`: required Terraform and provider versions.
- `variables.tf`: configurable inputs and safe defaults.
- `main.tf`: AKS, Storage, identity, federation, and RBAC resources.
- `outputs.tf`: values required by kubectl and the Velero installation.
- `terraform.tfvars.example`: safe template for the ignored local variables.

## Local preparation

Run these commands from WSL:

```bash
cd /mnt/c/Users/Utilisateur/Documents/Gitlab_Projets/aks-velero-azure-backup/terraform

export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

terraform fmt -check
terraform init
terraform validate
terraform plan -out=lab.tfplan
terraform show lab.tfplan
```

`ARM_SUBSCRIPTION_ID` is kept only in the current terminal session. The
subscription ID is not written to the repository.

The first `terraform plan` is a preview. It does not create anything. Do not
run `terraform apply` until every planned action has been reviewed.

## State strategy

The first lab plan uses local state because the project does not yet own a
remote state Storage account. Before treating this as a production design, the
state must be migrated to a protected Azure Blob backend. Terraform state and
plan files are ignored by Git.
