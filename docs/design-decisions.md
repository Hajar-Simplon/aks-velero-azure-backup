# Design Decisions

## Confirmed starting decisions

| Decision | Choice | Reason |
|---|---|---|
| Environment | Dev/test lab | The brief has a two-day delivery window. |
| AKS mode | Standard | Predictable control over identity and networking for learning. |
| Pod networking | Azure CNI Overlay | Scalable private pod addressing without consuming VNet IPs per pod. |
| Authentication | Workload Identity | Avoids long-lived storage account keys and client secrets. |
| Infrastructure | Terraform | Reproducible AKS, Storage, identity, and RBAC configuration. |
| Blob container | Private | Backups must not be anonymously accessible. |
| Initial redundancy | LRS | Cost-controlled baseline; cross-region replication remains a bonus. |
| Resource group | Existing external resource | Name supplied locally; reference only and never delete or manage with Terraform. |

## Non-negotiable resource-group guardrail

The existing resource group is outside this project's lifecycle. Its real name
must not appear in the repository. Terraform reads it with a data source and an
input variable rather than creating or importing it:

```hcl
data "azurerm_resource_group" "training" {
  name = var.resource_group_name
}
```

Forbidden operations include:

- deleting the externally managed resource group;
- `terraform destroy` against a configuration that manages the resource group;
- importing the resource group as `azurerm_resource_group`;
- renaming or replacing the resource group.

Cleanup inside the resource group is allowed. `terraform destroy` may remove
the AKS cluster, Storage account, managed identity, role assignments, federated
credential, and other resources managed by this project. Before cleanup, the
plan must be checked to confirm that the resource group itself is not a destroy
target.

## Decisions still to confirm before deployment

- Azure subscription context discovered through `az account show`.
- Deployment region after quota and SKU validation.
- AKS node VM size and node count based on available quota and lab budget.
- Terraform remote-state backend location.
- Whether the network-restriction bonus is included in the first deployment.
- Whether soft delete is mandatory for the first deployment or added afterward.
