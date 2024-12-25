variable "azure_rg_name" {
  type        = string
  description = "Azure RG Name"
  default     = "zit-prod-rg"
}

variable "azure_location" {
  type        = string
  description = "Azure region"
  default     = "Germany West Central"
}

variable "virtual_network_name" {
  type        = string
  default     = "zitprodvnet"
  description = "Name of virtual network"
}


variable "virtual_subnet_name" {
  type        = string
  default     = "zitprodsubnet"
  description = "Mein virtuelles subnet"

}

variable "public_ip_name" {
  default     = "zitip2023"
  description = "name of the public ip"

}

variable "network_security_group_name" {
  default     = "zitprodnsg"
  description = "Name of NSG"

}

variable "network_nic_name" {
  default     = "zitprodnic"
  description = "Name of the NIC"
}

variable "prefix" {
  type        = string
  default     = "win-iis"
  description = "Name of "

}