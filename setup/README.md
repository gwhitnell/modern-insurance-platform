## Data Setup

Run the following in Snowflake (or Snowsight):

1. Reset tables
   run: 01_reset.sql

2. Load sample data
   run: 02_seed_raw_data.sql

3. Validate
   SELECT COUNT(*) FROM RAW.BUSINESS_EVENTS;