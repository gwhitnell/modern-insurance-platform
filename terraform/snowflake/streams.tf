resource "snowflake_stream_on_table" "business_events_stream" {
  for_each = var.enable_streams_and_tasks ? local.env_databases : tomap({})

  name     = "BUSINESS_EVENTS_STREAM"
  database = each.value
  schema   = "RAW"

  table = "${each.value}.RAW.BUSINESS_EVENTS"

  append_only = true

  depends_on = [
    snowflake_table.raw_table,
    snowflake_schema.layer_schema,
  ]
}
