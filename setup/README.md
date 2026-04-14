## Data Setup

Run the following in Snowflake (or Snowsight):

1. Reset tables
   run: 01_reset.sql

2. Load sample data
   run: 02_seed_raw_data.sql

3. Validate
   SELECT COUNT(*) FROM RAW.BUSINESS_EVENTS;

Production-style data:

1. Reset PRD raw tables
   run: 03_reset_prd.sql

2. Load cleaner, story-driven PRD data
   run: 04_seed_prd_story_data.sql

This PRD seed creates:

- 24 months of sales activity across 2023 and 2024
- 1,320 sold policies
- Cleaner customer, policy, claim, and event records than the DEV demo seed
- A trend story with growth in sales volume, increased digital acquisition, renewals, MTAs, cancellations, lapses, and claims
