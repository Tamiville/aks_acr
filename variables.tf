variable "acr_rg" {
  type    = string
  default = "elite_container_registry_rg"
}

variable "location" {
  type    = string
  default = "North Europe"
}

/*****************
 * AKS VARIABLES *
 *****************/
variable "cluster_rg" {
  type    = string
  default = "elite_cluster_rg"
}

variable "cluster" {
  type    = string
  default = "elitekubecluster"
}

variable "dns_prefix" {
  type    = string
  default = "k8stest"
}

variable "agent_count" {
  default = 5
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  type    = string
  default = "PerGB2018"
}

# variable "cluster" {
#     type = string
#   default = "elitekubecluster"
# }