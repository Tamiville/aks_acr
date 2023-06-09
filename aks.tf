#############################################
############## SERVICE PRINCIPAL ############

#Create Azure AD App Registration
resource "azuread_application" "elitekubecluster" {
  display_name = "elitekubecluster"
}

resource "azuread_service_principal" "elitekubecluster-SP" {
  application_id = azuread_application.elitekubecluster.application_id
}

resource "azuread_service_principal_password" "elitekubecluster-SP" {
  service_principal_id = azuread_service_principal.elitekubecluster-SP.id
}

#############################################
########### Cluster Resource Group ##########
resource "azurerm_resource_group" "cluster_rg" {
  name     = var.cluster_rg
  location = var.location
}

#############################################
############ Analytical Workspace ###########
resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "eliteAnalytics" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.location
  resource_group_name = var.cluster_rg
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "eliteAnalytics" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.eliteAnalytics.location
  resource_group_name   = var.cluster_rg
  workspace_resource_id = azurerm_log_analytics_workspace.eliteAnalytics.id
  workspace_name        = azurerm_log_analytics_workspace.eliteAnalytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# /*******
#  * AKS *
#  *******/
resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster
  location            = var.location
  resource_group_name = var.cluster_rg
  dns_prefix          = var.dns_prefix

  # depends_on = [azurerm_resource_group.cluster_rg]

  linux_profile {
    admin_username = "adminuser"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxoF3pJuaLCErOLGqhwihkE5aeriKKg78L7zVuERbLkWL8JMgmaNQf8je7s2bGM83k9mMlnhtCCDL1YZr4V/cSD3tQrjXqL8z3JB/gTCoc0227kRlVXo6puCX+BrB1mgnqa5p+xGY45nMqLoCYHk809Q+7+UtOG9inNl08haLhcruAxbvL4o2XKHCBr02frnIVw7qIfX1ssw3qrEnsqrqi5vdOpODJXplqS1JAGQjLFxqGlB4qiFv7l9FfO2nEYxDc2T5BN/2fc+4uzPE4UPHaNYpmBpflm0gCy/xTmmOWfUt+9aiU+wTQSjbue/gbyp4XZc7NJCkplNBrfZpLOaNzQDbDpIRn7vBz52sMWiiDm+Fh0alX+4XOKZw6zOalo54t2Ttk6d2Mq/7Eh96pVblbf4BNQT9C7EEb3+p2CKq6pqmvb26X51cA5hukNR1FWIxmqg+4nikH3J5Ln+4GzH2SMy765duFYY287prIrlkal8BSdB68Re6p00JDOMu1vm1veBovtoQE3jT1Zw9MeuBOKCTeItqZZO8KJSclsUFGgEi/iqyKqazFXvwxEjg1WsepAs7IKisWP2YbXS0i0U9MazLUv+TRo8d5urL8I+mg/o4sV2CxqRFIAalO9CLhmZDxI74Vz8buRQLZr6yd9l9Dq3O/q/AB89P+DNPu3lXanw== devopslab@Tamie-Emmanuel"
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = azuread_service_principal.elitekubecluster-SP.application_id
    client_secret = azuread_service_principal_password.elitekubecluster-SP.value
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }

  tags = local.common_tags
}
