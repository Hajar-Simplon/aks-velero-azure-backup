# Prerequisites and Capacity Validation

This document records the checks completed before provisioning the Azure
infrastructure. The validation phase was read-only.

## Tooling

The implementation requires:

- Azure CLI for Azure authentication and resource inspection;
- Terraform for infrastructure provisioning;
- kubectl for AKS administration;
- Velero CLI for backup and restore operations.

Versions validated for this implementation:

| Tool | Version |
|---|---:|
| Azure CLI | 2.87.0 |
| Terraform | 1.15.8 |
| kubectl client | 1.34.9 |
| Velero client | 1.18.2 |
| Azure quota extension | 1.0.0 |

## Azure scope

The target Azure subscription was active and enabled. The existing
`hmezouarRG` resource group was successfully resolved in `francecentral`.
Terraform references this group as a data source; the group is not managed by
this project.

No existing AKS cluster was found in the target resource group during the
initial assessment.

## Regional compute capacity

Capacity was checked before selecting the AKS node size.

| Quota | Used | Limit | Available |
|---|---:|---:|---:|
| Total regional vCPUs | 16 | 32 | 16 |
| Dv3 family vCPUs | 6 | 10 | 4 |
| DSv3 family vCPUs | 10 | 10 | 0 |
| Dv5 / DSv5 family vCPUs | 0 | 0 | 0 |

The Microsoft Quota API was not available to the assigned training identity.
Azure Compute usage data was therefore used as the read-only fallback.

## Resulting baseline

The validated baseline is:

- AKS region: `westeurope`;
- Storage and identity region: `francecentral`;
- AKS mode: Standard;
- system node pool: one `Standard_D2_v3` node;
- pod networking: Azure CNI Overlay with Cilium;
- identity: OIDC issuer and Microsoft Entra Workload Identity.

France Central had no VM size satisfying all three constraints: assigned Azure
Policy, AKS regional availability, and remaining family quota. West Europe had
six Dv3-family vCPUs and four total regional vCPUs available, so the
policy-approved `Standard_D2_v3` was selected there. Storage remains in France
Central. This illustrates why quota, governance policy, and regional SKU
availability must all be validated in a shared subscription.
