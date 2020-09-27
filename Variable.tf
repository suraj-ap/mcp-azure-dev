variable "resource_group" {
  description = "The name of MCP Development environment Resource Group."
  default     = "MCP-Dev-RG01"
}

variable "prefix" {
  description = "This prefix will be included in the name of some resources."
  default     = "mcp-dev-"
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "Central India"
}

variable "virtual_network_name" {
  description = "The name for your virtual network."
  default     = "MCP-Dev-Vnet01"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "192.168.0.0/24"
}

variable "web_subnet_prefix" {
  description = "The address prefix to use for the Web Tier subnet."
  default     = "192.168.0.0/26"

  variable "app_subnet_prefix" {
  description = "The address prefix to use for the App Tier subnet."
  default     = "192.168.0.64/26"

  variable "data_subnet_prefix" {
  description = "The address prefix to use for the Data Tier subnet."
  default     = "192.168.0.128/26"

  variable "dmz_subnet_prefix" {
  description = "The address prefix to use for the DMZ Tier subnet."
  default     = "192.168.0.192/27"

  variable "gw_subnet_prefix" {
  description = "The address prefix to use for the Gateway Tier subnet."
  default     = "192.168.0.224/27"