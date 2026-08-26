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
| Storage authentication | Workload Identity only | Storage account keys and local users are disabled. |
| Initial redundancy | LRS | Cost-controlled baseline; cross-region replication remains a bonus. |
| Resource group | Existing `hmezouarRG` | Reference only; never create, import, manage, or delete with Terraform. |

## Validated deployment baseline

- Azure CLI context: authenticated, enabled default subscription.
- Deployment region: `francecentral`.
- AKS node pool: one `Standard_D2_v3` node for this dev/test lab.
- Capacity basis: 4 Dv3-family vCPUs available during validation; the node
  requires 2 vCPUs.

## Decisions still to confirm before deployment

- Terraform remote-state backend location.
- Whether the network-restriction bonus is included in the first deployment.
- Whether soft delete is mandatory for the first deployment or added afterward.
