############################################
# LOADER: INSERT INTO RAW
############################################

resource "snowflake_grant_privileges_to_account_role" "loader_insert_raw_dev" {
  account_role_name = "ROLE_LOADER"
  privileges        = ["INSERT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.RAW"
    }
  }
}

############################################
# TRANSFORM: FULL ACCESS CLEAN + ANALYTICS
############################################

resource "snowflake_grant_privileges_to_account_role" "transform_all_clean_dev" {
  account_role_name = "ROLE_TRANSFORM"
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.CLEAN"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transform_all_analytics_dev" {
  account_role_name = "ROLE_TRANSFORM"
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }
}

############################################
# ANALYST: READ ONLY ANALYTICS
############################################

resource "snowflake_grant_privileges_to_account_role" "analyst_select_analytics_dev" {
  account_role_name = "ROLE_ANALYST"
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }
}

############################################
# FUTURE GRANTS
############################################

# Automatically grant access to new tables created by dbt

resource "snowflake_grant_privileges_to_account_role" "analyst_future_select_analytics_dev" {
  account_role_name = "ROLE_ANALYST"
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transform_future_all_clean_dev" {
  account_role_name = "ROLE_TRANSFORM"
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.CLEAN"
    }
  }
}