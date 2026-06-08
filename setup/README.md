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

## Snowflake Intelligence

After the PRD data has been loaded and dbt has built the PRD marts, run:

1. Build PRD marts
   run: `dbt run --target prd --full-refresh`

2. Create the semantic view and Snowflake Intelligence Agent
   run: `05_snowflake_intelligence.sql`

3. Open Snowflake Intelligence, switch to `ROLE_ANALYST`, and select:
   `Insurance Performance`

The script creates this Agent object:
`SNOWFLAKE_INTELLIGENCE.AGENTS.INSURANCE_PERFORMANCE_AGENT`

The Agent is backed by two semantic views:

- `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE`
- `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.CUSTOMER_SERVICE_LOOKUP`

`INSURANCE_PERFORMANCE` handles aggregate performance analysis.
`CUSTOMER_SERVICE_LOOKUP` handles bounded customer service searches over the
same demo customer, policy, and claim marts used by the Streamlit app.

Suggested first questions:

- What was total net premium movement by product last month?
- Show claims paid by product over time.
- Which product has the highest cancellation volume?
- Compare new business and renewals by month.
- Find customers called Ruby.
- Look up policy P100123.
- Show claim CL200126.
