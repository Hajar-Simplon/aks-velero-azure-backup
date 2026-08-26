variable "resource_group_name" {
  description = "Name of the existing externally managed resource group."
  type        = string
  default     = "hmezouarRG"
}

variable "location" {
  description = "Azure region used for Storage and managed identity resources."
  type        = string
  default     = "francecentral"
}

variable "aks_location" {
  description = "Azure region used for the AKS cluster."
  type        = string
  default     = "westeurope"
}

variable "name_prefix" {
  description = "Short prefix used to name resources created by this project."
  type        = string
  default     = "velerolab"

  validation {
    condition     = can(regex("^[a-z0-9]{3,12}$", var.name_prefix))
    error_message = "name_prefix must contain 3-12 lowercase letters or numbers."
  }
}

variable "node_vm_size" {
  description = "VM size for the single-node AKS lab pool."
  type        = string
  default     = "Standard_D2_v3"
}

variable "node_count" {
  description = "Number of AKS nodes for this dev/test lab."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "node_count must be between 1 and 3 for this lab."
  }
}

variable "enable_blob_soft_delete" {
  description = "Enable the optional Blob soft-delete protection."
  type        = bool
  default     = false
}

variable "aks_outbound_public_ips" {
  description = "Public egress IP addresses used by AKS and allowed through the Storage firewall."
  type        = list(string)

  validation {
    condition = length(var.aks_outbound_public_ips) > 0 && alltrue([
      for ip in var.aks_outbound_public_ips : can(cidrhost("${ip}/32", 0)) && !strcontains(ip, "/")
    ])
    error_message = "aks_outbound_public_ips must contain at least one plain IPv4 address without CIDR notation."
  }
}

variable "simplon_public_ips" {
  description = "Simplon site public IP addresses allowed through the Storage firewall."
  type        = list(string)

  validation {
    condition = length(var.simplon_public_ips) > 0 && alltrue([
      for ip in var.simplon_public_ips : can(cidrhost("${ip}/32", 0)) && !strcontains(ip, "/")
    ])
    error_message = "simplon_public_ips must contain at least one plain IPv4 address without CIDR notation."
  }
}

variable "tags" {
  description = "Tags applied to project resources."
  type        = map(string)
  default = {
    project     = "aks-velero-azure-backup"
    environment = "lab"
    managed_by  = "terraform"
  }
}
