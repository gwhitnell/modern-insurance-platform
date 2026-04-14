resource "snowflake_table" "stg_business_events_incremental" {
  for_each = var.enable_streams_and_tasks ? local.env_databases : tomap({})

  database = each.value
  schema   = "CLEAN"
  name     = "STG_BUSINESS_EVENTS_INCREMENTAL"
  comment  = "Incremental staging table populated by the business events stream task."

  column {
    name = "EVENT_ID"
    type = "VARCHAR"
  }

  column {
    name = "POLICY_ID"
    type = "VARCHAR"
  }

  column {
    name = "EVENT_TS"
    type = "VARCHAR"
  }

  column {
    name = "EVENT_TYPE"
    type = "VARCHAR"
  }

  column {
    name = "CHANNEL"
    type = "VARCHAR"
  }

  column {
    name = "GROSS_PREMIUM_CHANGE"
    type = "VARCHAR"
  }

  column {
    name = "EVENT_VERSION"
    type = "VARCHAR"
  }

  column {
    name = "SOURCE_SYSTEM"
    type = "VARCHAR"
  }

  column {
    name = "INGESTED_AT"
    type = "TIMESTAMP_NTZ"
  }

  depends_on = [
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_task" "business_events_task" {
  for_each = var.enable_streams_and_tasks ? local.env_databases : tomap({})

  name      = "BUSINESS_EVENTS_TASK"
  database  = each.value
  schema    = "RAW"
  warehouse = var.warehouse_name

  started = true

  schedule {
    minutes = 1
  }

  sql_statement = <<EOT
INSERT INTO ${each.value}.CLEAN.STG_BUSINESS_EVENTS_INCREMENTAL (
    EVENT_ID,
    POLICY_ID,
    EVENT_TS,
    EVENT_TYPE,
    CHANNEL,
    GROSS_PREMIUM_CHANGE,
    EVENT_VERSION,
    SOURCE_SYSTEM,
    INGESTED_AT
)
SELECT
    EVENT_ID,
    POLICY_ID,
    EVENT_TS,
    EVENT_TYPE,
    CHANNEL,
    GROSS_PREMIUM_CHANGE,
    EVENT_VERSION,
    SOURCE_SYSTEM,
    COALESCE(INGESTED_AT, CURRENT_TIMESTAMP())
FROM ${each.value}.RAW.BUSINESS_EVENTS_STREAM
WHERE METADATA$ACTION = 'INSERT'
EOT

  depends_on = [
    snowflake_warehouse.platform_wh,
    snowflake_stream_on_table.business_events_stream,
    snowflake_table.stg_business_events_incremental,
    snowflake_schema.layer_schema,
  ]
}
