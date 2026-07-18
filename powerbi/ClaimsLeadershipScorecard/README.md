# Claims Leadership Scorecard

Open `ClaimsLeadershipScorecard.pbip` in Power BI Desktop. On first refresh, authenticate to Snowflake and confirm the parameter values in the semantic model. Credentials are intentionally not stored in this project.

The report uses Import mode against `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.FCT_CLAIMS` and `DIM_POLICY`. Paid values are paid-to-date and must not be interpreted as incurred loss or outstanding reserve.
