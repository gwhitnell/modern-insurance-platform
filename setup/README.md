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

The Snowflake semantic-view definitions are maintained in
`dbt/macros/create_semantic_views.sql`. They resolve their source relations from
the selected dbt target, so the same operations can be used in DEV and PRD.

After the data has been loaded and dbt has built the marts, run from the
repository root:

1. Create or update all three semantic views in DEV
   `dbt run-operation create_semantic_views --project-dir dbt --target dev`

2. Check the DEV views in Snowsight, Cortex Analyst, or Snowflake Intelligence

3. Create or update all three semantic views in PRD
   `dbt run-operation create_semantic_views --project-dir dbt --target prd`

The individual operations are also available when only one view should change:

- `create_claims_semantic_view`
- `create_insurance_performance_semantic_view`
- `create_customer_service_lookup_semantic_view`

The operations create these views in the selected target's analytics schema:

- `CLAIMS_SEMANTIC_VIEW`
- `INSURANCE_PERFORMANCE`
- `CUSTOMER_SERVICE_LOOKUP`

For the existing PRD Snowflake Intelligence Agent setup:

1. Build PRD marts
   from the repository root, run: `cd dbt && dbt run --target prd --full-refresh`

2. Create the PRD semantic views with the dbt operation above

3. Run the grants and Snowflake Intelligence Agent portions of
   `05_snowflake_intelligence.sql`. The semantic-view DDL retained in that file
   is legacy bootstrap SQL; the dbt macros are the canonical definitions.

4. Open Snowflake Intelligence, switch to `ROLE_ANALYST`, and select:
   `Insurance Performance`

The script creates this Agent object:
`SNOWFLAKE_INTELLIGENCE.AGENTS.INSURANCE_PERFORMANCE_AGENT`

The existing Agent is backed by two semantic views:

- `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE`
- `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.CUSTOMER_SERVICE_LOOKUP`

`INSURANCE_PERFORMANCE` handles aggregate performance analysis.
`CUSTOMER_SERVICE_LOOKUP` handles bounded customer service searches over the
same demo customer, policy, and claim marts used by the Streamlit app.

`CLAIMS_SEMANTIC_VIEW` is the claims-focused model aligned with
`dbt/models/marts/claims_sematic.yml`; add it to an Agent as another Cortex
Analyst tool when you want the claims scorecard measures exposed directly.

Suggested first questions:

- What was total net premium movement by product last month?
- Show claims paid by product over time.
- Which product has the highest cancellation volume?
- Compare new business and renewals by month.
- Find customers called Ruby.
- Look up policy P100123.
- Show claim CL200126.

## Horizon Catalog

dbt persists model and column descriptions as Snowflake comments, making the
documentation in `dbt/models/**/schema.yml` searchable in Horizon Catalog.

After both dbt environments and the PRD semantic views exist, run:

1. `08_horizon_catalog.sql` as `ACCOUNTADMIN`.
2. Open Snowsight and select **Catalog > Explorer**.
3. Review the PRD `ANALYTICS` objects, their tags, descriptions, and lineage.
4. Search for `trusted insurance`, `customer personal data`, or
   `monthly policy performance` to validate discovery metadata.

The script creates a controlled tag vocabulary in
`PRD_MODERN_INSURANCE_PLATFORM.GOVERNANCE`, marks RAW as source-only, marks the
PRD marts and semantic views as trusted, and classifies personal-data columns
on `DIM_CUSTOMER`. It is safe to rerun. Object tagging might require Enterprise
Edition or higher; if the trial account rejects `CREATE TAG`, retain the dbt
comments and rerun this script after upgrading.

Tags and comments contain metadata only. Never store customer names, email
addresses, dates of birth, policy numbers, claim numbers, or other record-level
values in catalog metadata.
