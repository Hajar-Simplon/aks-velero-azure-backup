# Infrastructure Deployment

## Result

The Azure infrastructure required by Velero was deployed successfully with
Terraform and recorded in a remote Azure Blob backend.

| Component | Result |
|---|---|
| AKS cluster | Running in West Europe |
| AKS system pool | One `Standard_D2_v3` node |
| Node status | `Ready` |
| OIDC issuer | Enabled |
| Workload Identity | Enabled |
| Backup Storage account | Deployed in France Central |
| Blob container | Private `velero` container |
| Velero managed identity | Deployed |
| Blob RBAC | `Storage Blob Data Contributor` |
| Federated identity | Bound to `system:serviceaccount:velero:velero` |
| Terraform backend | Remote Azure Blob state |

## Regional placement

The existing resource group is not managed by Terraform. Storage and managed
identity resources were deployed in France Central. AKS was deployed in West
Europe because the shared training subscription had no France Central VM size
that simultaneously met Azure Policy, regional availability, and remaining
quota constraints.

West Europe provided sufficient quota for the policy-approved
`Standard_D2_v3` size. This placement changes neither the Blob authentication
model nor the Kubernetes backup workflow.

## Deployment recovery

The initial France Central deployment attempts exposed two environment
constraints:

1. Dv3-family quota became fully consumed between validation and deployment.
2. An assigned Azure Policy restricted the allowed VM sizes, while the
   remaining policy-approved alternative was unavailable for AKS in the region.

The failed, node-less AKS resource was imported into remote Terraform state,
assessed, and replaced in West Europe. The Storage account, containers,
identity, RBAC assignments, remote state, and existing resource group were
preserved. The successful deployment plan created the replacement cluster
without deleting any data-bearing resource.

## Verification

Post-deployment checks confirmed:

- AKS provisioning state: `Succeeded`;
- AKS power state: `Running`;
- system node: `Ready`;
- node VM size: `Standard_D2_v3`;
- OIDC issuer and Workload Identity: enabled;
- private `velero` Blob container: present;
- remote state object `aks-velero.tfstate`: present.

No access keys, tokens, kubeconfig content, subscription identifiers, or state
contents are included in this documentation.
