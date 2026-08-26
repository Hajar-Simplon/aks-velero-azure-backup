# 01 — Workstation and Azure Validation

This phase checks that the workstation and Azure environment are ready before
any infrastructure is created. All commands in this phase are read-only.

## Mental model

```text
Local workstation
  |-- Azure CLI    -> talks to Azure
  |-- Terraform    -> will create the lab infrastructure
  |-- kubectl      -> will control AKS
  `-- Velero CLI   -> will request backups and restores

Azure subscription
  `-- existing hmezouarRG resource group (reference only)
      |-- AKS cluster                 [not created yet]
      `-- Storage account/container   [not created yet]
```

## 1. Check the Azure login

```bash
az account show --query '{subscriptionName:name,state:state,isDefault:isDefault}' -o json
```

What it proves:

- the Azure CLI is authenticated;
- the active subscription is enabled;
- the command will use the default subscription.

Do not copy a subscription ID into the repository.

## 2. Check the existing resource group

```bash
az group show \
  --name "hmezouarRG" \
  --query '{location:location,provisioningState:properties.provisioningState}' \
  -o json
```

Expected result:

```text
location: francecentral
provisioningState: Succeeded
```

This project will read the group as an existing object. It will never create,
import, rename, or delete the group.

## 3. Check whether an AKS cluster already exists

```bash
az aks list \
  --resource-group "hmezouarRG" \
  --query '[].{name:name,location:location,kubernetesVersion:kubernetesVersion}' \
  -o table
```

An empty table was returned during validation, so the new lab cluster will not
overlap an existing AKS cluster.

## 4. Check the tools

```bash
az version
terraform version
kubectl version --client
velero version --client-only
az extension show --name quota
```

Validated workstation versions:

- Azure CLI: 2.87.0
- Terraform: 1.15.8
- kubectl client: 1.34.9
- Velero client: 1.18.2
- Azure quota extension: 1.0.0

## 5. Check regional compute quota

```bash
az vm list-usage --location francecentral -o table
```

Relevant result at validation time:

| Quota | Used | Limit | Available |
|---|---:|---:|---:|
| Total regional vCPUs | 16 | 32 | 16 |
| Dv3 family vCPUs | 6 | 10 | 4 |
| DSv3 family vCPUs | 10 | 10 | 0 |
| Dv5 / DSv5 family vCPUs | 0 | 0 | 0 |

The Microsoft Quota API returned `AuthorizationFailed` for this training
account, so the read-only Compute usage command was used as the fallback.

## Decision

The initial lab design uses:

- region: `francecentral`;
- one AKS node;
- node size: `Standard_D2_v3` (2 vCPUs, within the 4 available Dv3 vCPUs);
- AKS Standard with Azure CNI Overlay;
- OIDC issuer and Workload Identity enabled.

No Azure resource was created, modified, or deleted during this phase.

## Evidence to keep

No screenshot is required yet. The final evidence should focus on the brief's
results: AKS nodes ready, Velero storage available, backup completed, blobs in
Azure Storage, namespace deletion, and successful restoration.
