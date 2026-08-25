# Terraform

This directory will contain the AKS, Azure Storage, managed identity, federated
credential, and RBAC configuration after the Azure account, region, quota,
node-size, and remote-state decisions are validated.

Do not run `terraform apply` until the generated plan has been reviewed.

## Protected resource group

The externally managed resource group must be referenced with an
`azurerm_resource_group` data source and `var.resource_group_name`. Its actual
name is supplied only through an ignored local `.tfvars` file. Never define,
import, rename, or destroy the resource group through this project. Resources
created inside it by this Terraform configuration may be removed with
`terraform destroy`, after confirming that the group itself is not targeted.
