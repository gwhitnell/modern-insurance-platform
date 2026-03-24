resource "snowflake_task" "business_events_task" {
  name      = "BUSINESS_EVENTS_TASK"
  database  = var.dev_database_name
  schema    = "RAW"
  warehouse = var.warehouse_name

  started = true

  schedule {
    minutes = 1
  }

  sql_statement = <<EOT
INSERT INTO ${var.dev_database_name}.CLEAN.BUSINESS_EVENTS_INCREMENTAL
SELECT
    EVENT_ID,
    POLICY_ID,
    EVENT_TS,
    EVENT_TYPE,
    CHANNEL,
    GROSS_PREMIUM_CHANGE,
    EVENT_VERSION,
    SOURCE_SYSTEM,
    INGESTED_AT
FROM ${var.dev_database_name}.RAW.BUSINESS_EVENTS_STREAM
WHERE METADATA$ACTION = 'INSERT'
EOT
}