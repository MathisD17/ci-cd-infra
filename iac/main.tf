data "azurerm_resource_group" "rg_nlouineau_k8s" {
  name = "rg-NLouineau2024_cours-projet"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = data.azurerm_resource_group.rg_nlouineau_k8s.location
  resource_group_name = data.azurerm_resource_group.rg_nlouineau_k8s.name
  name                = "cluster-nl"
  dns_prefix          = "k8s-nl-noeud"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2S"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  tags = {
    "BypassPermAllRestrict" = "false"
    "BypassTempAllRestrict" = "false"
    "cours"                 = "cours-projet"
    "promotion"             = "HASDO_001"
    "user"                  = "NLouineau2024"
  }
}
