variable "sql_location" {
  description = "Azure region used for the Azure SQL logical server. Keep this independent from the AKS/resource-group region because SQL provisioning can be region restricted."
  type        = string
  default     = "Central US"
}
