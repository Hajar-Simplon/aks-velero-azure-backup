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
- `backend.tf`: remote Azure Blob state backend.
- `variables.tf`: configurable inputs and safe defaults.
- `main.tf`: AKS, Storage, identity, federation, and RBAC resources.
- `outputs.tf`: values required by kubectl and the Velero installation.
- `terraform.tfvars.example`: example environment values.

## Validation policy

All changes must pass formatting and configuration validation. A saved plan
must be reviewed before deployment and must contain no unexpected changes or
destructive actions.

Terraform state, saved plans, credentials, and provider caches are excluded
from version control.

## State strategy

The environment uses an Azure Blob backend rather than relying on local state.
The state container is separate from the container used for Velero backups and
uses Microsoft Entra authentication.
