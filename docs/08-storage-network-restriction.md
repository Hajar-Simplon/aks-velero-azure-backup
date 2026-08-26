# Storage Network Restriction

## Objective

The Velero Storage account must reject data-plane traffic by default and accept
it only from:

- the AKS cluster's stable outbound public IP;
- the approved public IP of the Simplon site.

The Blob container remains private, and Microsoft Entra authorization is still
required after a connection passes the network firewall. Network authorization
and identity authorization therefore protect separate layers.

## Terraform configuration

The Storage account uses a deny-by-default firewall:

```hcl
network_rules {
  default_action = "Deny"
  bypass         = ["None"]
  ip_rules = distinct(concat(
    var.aks_outbound_public_ips,
    var.simplon_public_ips,
  ))
}
```

The environment-specific IP addresses are supplied through the ignored
`terraform.tfvars` file. Only documentation-only example addresses are stored
in Git. The public endpoint remains enabled because it carries the allowlisted
traffic; `default_action = "Deny"` blocks all other source addresses.

## Deployment safety

The reviewed Terraform plan contained:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Only the existing Storage account was changed in place. The AKS cluster,
managed identity, Blob container, backups, and externally managed resource
group were not recreated or deleted.

## Verification

The deployed Storage firewall reported:

| Setting | Result |
|---|---|
| Public network access | `Enabled` for allowlisted traffic |
| Default action | `Deny` |
| Trusted-service bypass | `None` |
| Allowed sources | AKS outbound IP and Simplon public IP only |

Access from the Simplon connection succeeded using Microsoft Entra
authentication, confirming that the approved site remained operational.

A new Velero backup named `network-restriction-test` was then created from
inside AKS. It completed with zero errors and zero warnings, and ten objects
were written under `backups/network-restriction-test/` in Azure Blob Storage.
The BackupStorageLocation also remained `Available` in `ReadWrite` mode.

## Security result

An unlisted source cannot reach the Storage data plane. An allowlisted source
must still authenticate and possess the appropriate Azure RBAC permissions.
Velero continues to use Workload Identity, so the network restriction does not
introduce Storage keys, SAS tokens, or client secrets.

## Operational note

Public egress addresses can change if the AKS outbound configuration or the
Simplon internet connection changes. Update the corresponding Terraform
variable and apply a reviewed plan before removing an address that is still in
use.
