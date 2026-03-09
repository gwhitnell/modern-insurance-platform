provider "snowflake" {
  account  = var.snowflake_account_identifier
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}
