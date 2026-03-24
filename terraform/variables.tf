variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username used by Terraform."
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password used by Terraform."
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role for Terraform actions."
  type        = string
  default     = "ACCOUNTADMIN"
}

variable "warehouse_name" {
  description = "Primary warehouse for the project."
  type        = string
  default     = "MODERN_INSURANCE_PLATFORM_WH"
}

variable "dev_database_name" {
  description = "Development database name."
  type        = string
  default     = "DEV_MODERN_INSURANCE_PLATFORM"
}

variable "prd_database_name" {
  description = "Production database name."
  type        = string
  default     = "PRD_MODERN_INSURANCE_PLATFORM"
}

variable "schema_names" {
  description = "Layered schema names created in each environment database."
  type        = set(string)
  default     = ["RAW", "CLEAN", "ANALYTICS"]
}
