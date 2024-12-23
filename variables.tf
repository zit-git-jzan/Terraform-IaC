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