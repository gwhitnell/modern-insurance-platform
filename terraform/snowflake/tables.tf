locals {
  raw_table_definitions = {
    CUSTOMERS = {
      comment = "Raw customer records landed from source systems."
      columns = [
        { name = "CUSTOMER_ID", type = "VARCHAR" },
        { name = "FIRST_NAME", type = "VARCHAR" },
        { name = "LAST_NAME", type = "VARCHAR" },
        { name = "DOB", type = "VARCHAR" },
        { name = "EMAIL", type = "VARCHAR" },
        { name = "CREATED_AT", type = "VARCHAR" },
        { name = "SOURCE_SYSTEM", type = "VARCHAR" },
      ]
    }
    POLICIES = {
      comment = "Raw policy records landed from source systems."
      columns = [
        { name = "POLICY_ID", type = "VARCHAR" },
        { name = "CUSTOMER_ID", type = "VARCHAR" },
        { name = "PRODUCT_CODE", type = "VARCHAR" },
        { name = "INCEPTION_DATE", type = "VARCHAR" },
        { name = "EXPIRY_DATE", type = "VARCHAR" },
        { name = "STATUS", type = "VARCHAR" },
        { name = "ANNUAL_PREMIUM", type = "VARCHAR" },
        { name = "SOURCE_SYSTEM", type = "VARCHAR" },
      ]
    }
    CLAIMS = {
      comment = "Raw claims records landed from source systems."
      columns = [
        { name = "CLAIM_ID", type = "VARCHAR" },
        { name = "POLICY_ID", type = "VARCHAR" },
        { name = "LOSS_DATE", type = "VARCHAR" },
        { name = "REPORTED_DATE", type = "VARCHAR" },
        { name = "CLAIM_STATUS", type = "VARCHAR" },
        { name = "PAID_AMOUNT", type = "VARCHAR" },
        { name = "SOURCE_SYSTEM", type = "VARCHAR" },
      ]
    }
    BUSINESS_EVENTS = {
      comment = "Raw business events landed from source systems."
      columns = [
        { name = "EVENT_ID", type = "VARCHAR" },
        { name = "POLICY_ID", type = "VARCHAR" },
        { name = "EVENT_TS", type = "VARCHAR" },
        { name = "EVENT_TYPE", type = "VARCHAR" },
        { name = "CHANNEL", type = "VARCHAR" },
        { name = "GROSS_PREMIUM_CHANGE", type = "VARCHAR" },
        { name = "EVENT_VERSION", type = "VARCHAR" },
        { name = "SOURCE_SYSTEM", type = "VARCHAR" },
      ]
    }
  }

  raw_table_matrix = merge([
    for env, db_name in local.env_databases : {
      for table_name, definition in local.raw_table_definitions :
      "${db_name}.RAW.${table_name}" => {
        database = db_name
        schema   = "RAW"
        name     = table_name
        comment  = definition.comment
        columns  = definition.columns
      }
    }
  ]...)
}

resource "snowflake_table" "raw_table" {
  for_each = local.raw_table_matrix

  database = each.value.database
  schema   = each.value.schema
  name     = each.value.name
  comment  = each.value.comment

  dynamic "column" {
    for_each = each.value.columns

    content {
      name = column.value.name
      type = column.value.type
    }
  }

  depends_on = [
    snowflake_schema.layer_schema,
  ]
}
