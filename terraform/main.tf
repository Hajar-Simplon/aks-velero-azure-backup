data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  resource_suffix = random_string.suffix.result
  aks_name        = "${var.name_prefix}-aks-${local.resource_suffix}"
  identity_name   = "${var.name_prefix}-velero-${local.resource_suffix}"

  # Storage account names must be globally unique and use only lowercase
  # letters and numbers. The prefix validation and random suffix enforce this.
  storage_account_name = "${var.name_prefix}${local.resource_suffix}"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = local.aks_name
  location            = var.aks_location
  resource_group_name = data.azurerm_resource_group.target.name
  dns_prefix          = local.aks_name
  sku_tier            = "Free"

  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true

  default_node_pool {
    name                        = "system"
    temporary_name_for_rotation = "systemtmp"
    node_count                  = var.node_count
    vm_size                     = var.node_vm_size
    os_disk_size_gb             = 64
    type                        = "VirtualMachineScaleSets"

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
  }

  tags = var.tags
}

resource "azurerm_storage_account" "velero" {
  name                     = local.storage_account_name
  resource_group_name      = data.azurerm_resource_group.target.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  local_user_enabled              = false

  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.enable_blob_soft_delete ? [1] : []

      content {
        days = 7
      }
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "velero" {
  name                  = "velero"
  storage_account_id    = azurerm_storage_account.velero.id
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "velero" {
  name                = local.identity_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.target.name
  tags                = var.tags
}

# Velero uses this role to write and read backup objects in the private Blob
# container without a storage account key.
resource "azurerm_role_assignment" "velero_blob_data" {
  scope                = azurerm_storage_account.velero.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.velero.principal_id
}

resource "azurerm_federated_identity_credential" "velero" {
  name                      = "velero-service-account"
  user_assigned_identity_id = azurerm_user_assigned_identity.velero.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.this.oidc_issuer_url
  subject                   = "system:serviceaccount:velero:velero"
}
