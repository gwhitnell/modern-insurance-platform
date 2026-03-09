terraform {
  required_version = ">= 1.6.0"

  required_providers {
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 1.0"
    }
  }
}
