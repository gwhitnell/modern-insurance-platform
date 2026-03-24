resource "snowflake_stream_on_table" "business_events_stream" {
  name     = "BUSINESS_EVENTS_STREAM"
  database = var.dev_database_name
  schema   = "RAW"

  table = "${var.dev_database_name}.RAW.BUSINESS_EVENTS"

  append_only = true
}