############################################
# LOADER: READ + RESET + INSERT INTO RAW
############################################

resource "snowflake_grant_privileges_to_account_role" "loader_manage_raw_dev" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["SELECT", "INSERT", "TRUNCATE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.RAW"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.loader_raw_usage_dev,
  ]
}

############################################
# TRANSFORM: FULL ACCESS CLEAN + ANALYTICS
############################################

resource "snowflake_grant_privileges_to_account_role" "transform_all_clean_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.CLEAN"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_clean_usage_dev,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_all_analytics_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_analytics_usage_dev,
  ]
}

############################################
# ANALYST: READ ONLY ANALYTICS
############################################

resource "snowflake_grant_privileges_to_account_role" "analyst_select_analytics_dev" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["SELECT"]

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.analyst_analytics_usage_dev,
  ]
}

############################################
# FUTURE GRANTS
############################################

# Automatically grant access to new tables created by dbt

resource "snowflake_grant_privileges_to_account_role" "loader_future_manage_raw_dev" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["SELECT", "INSERT", "TRUNCATE"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.RAW"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.loader_raw_usage_dev,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_select_analytics_dev" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.ANALYTICS"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.analyst_analytics_usage_dev,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_future_all_clean_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.dev_database_name}.CLEAN"
    }
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_clean_usage_dev,
  ]
}
