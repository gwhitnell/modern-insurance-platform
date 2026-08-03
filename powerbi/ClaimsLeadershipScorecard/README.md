# Claims Leadership Scorecard

Open `ClaimsLeadershipScorecard.pbip` in Power BI Desktop. On first refresh, authenticate to Snowflake and confirm the parameter values in the semantic model. Credentials are intentionally not stored in this project.

The report uses Import mode against the dbt-built Snowflake models in `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS`. Run and test the dbt production models before refreshing or publishing the report. For local development, change the `SnowflakeDatabase` parameter to `DEV_MODERN_INSURANCE_PLATFORM`. Paid values are paid-to-date and must not be interpreted as incurred loss or outstanding reserve.

The dbt semantic-model YAML governs reusable MetricFlow metric definitions, but Power BI Desktop does not import that YAML as a native Power BI semantic model. This PBIP project therefore retains its TMDL relationships and DAX measures while sourcing governed dimensions and facts from the dbt-built Snowflake marts.
