------------------------------------------------------------------------------
-- Snowflake Intelligence bootstrap
--
-- Run after:
--   1. Terraform has created PRD_MODERN_INSURANCE_PLATFORM.
--   2. PRD raw data has been seeded.
--   3. dbt has built the PRD marts into the ANALYTICS schema.
--
-- Purpose:
--   Creates a Snowflake native semantic view that Cortex Analyst can use as
--   the structured-data tool inside a Snowflake Intelligence Agent.
------------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE MODERN_INSURANCE_PLATFORM_WH;
USE DATABASE PRD_MODERN_INSURANCE_PLATFORM;
USE SCHEMA ANALYTICS;

------------------------------------------------------------------------------
-- Create the semantic view
------------------------------------------------------------------------------

CREATE OR ALTER SEMANTIC VIEW insurance_performance
  TABLES (
    policy_monthly AS PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.FCT_POLICY_MONTHLY
      PRIMARY KEY (policy_id, event_month)
      WITH SYNONYMS ('monthly policy performance', 'policy month rollup', 'insurance performance')
      COMMENT = 'Monthly policy performance rollup with business event and claims metrics.',

    policies AS PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.DIM_POLICY
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('policies', 'insurance policies', 'policy dimension')
      COMMENT = 'Policy attributes including product, status, premium, and lifecycle dates.'
  )
  RELATIONSHIPS (
    policy_monthly_to_policies AS
      policy_monthly (policy_id) REFERENCES policies
  )
  FACTS (
    policy_monthly.net_premium_change AS net_premium_change
      COMMENT = 'Premium movement during the month.',
    policy_monthly.claim_count AS claim_count
      COMMENT = 'Number of claims in the month.',
    policy_monthly.total_paid AS total_paid
      COMMENT = 'Total claims paid in the month.',
    policy_monthly.quote_count AS quote_count
      COMMENT = 'Number of quotes in the month.',
    policy_monthly.new_business_count AS new_business_count
      COMMENT = 'Number of new business events in the month.',
    policy_monthly.renewal_count AS renewal_count
      COMMENT = 'Number of renewal events in the month.',
    policy_monthly.cancellation_count AS cancellation_count
      COMMENT = 'Number of cancellation events in the month.',
    policy_monthly.lapse_count AS lapse_count
      COMMENT = 'Number of lapse events in the month.',
    policies.annual_premium AS annual_premium
      COMMENT = 'Annualized premium amount for a policy.'
  )
  DIMENSIONS (
    policy_monthly.event_month AS event_month
      WITH SYNONYMS ('month', 'calendar month', 'reporting month')
      COMMENT = 'Calendar month for the policy rollup.',
    policies.product_code AS product_code
      WITH SYNONYMS ('product', 'line of business', 'insurance product')
      COMMENT = 'Insurance product code, for example motor, home, or SME.',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('status', 'policy lifecycle status')
      COMMENT = 'Current policy lifecycle status.',
    policies.source_system AS source_system
      COMMENT = 'Source system that produced the policy record.'
  )
  METRICS (
    policy_monthly.policy_count AS COUNT(DISTINCT policy_id)
      WITH SYNONYMS ('number of policies', 'policies')
      COMMENT = 'Count of distinct policies.',
    policy_monthly.total_net_premium_change AS SUM(policy_monthly.net_premium_change)
      WITH SYNONYMS ('premium movement', 'net premium movement', 'premium change')
      COMMENT = 'Total net premium movement.',
    policy_monthly.total_claims AS SUM(policy_monthly.claim_count)
      WITH SYNONYMS ('claims', 'claim volume')
      COMMENT = 'Total number of claims.',
    policy_monthly.total_claims_paid AS SUM(policy_monthly.total_paid)
      WITH SYNONYMS ('claims paid', 'paid claims', 'claim payments')
      COMMENT = 'Total amount paid on claims.',
    policy_monthly.total_quotes AS SUM(policy_monthly.quote_count)
      WITH SYNONYMS ('quotes', 'quote volume')
      COMMENT = 'Total number of quote events.',
    policy_monthly.total_new_business AS SUM(policy_monthly.new_business_count)
      WITH SYNONYMS ('new business', 'new policies')
      COMMENT = 'Total number of new business events.',
    policy_monthly.total_renewals AS SUM(policy_monthly.renewal_count)
      WITH SYNONYMS ('renewals')
      COMMENT = 'Total number of renewal events.',
    policy_monthly.total_cancellations AS SUM(policy_monthly.cancellation_count)
      WITH SYNONYMS ('cancellations')
      COMMENT = 'Total number of cancellation events.',
    policy_monthly.total_lapses AS SUM(policy_monthly.lapse_count)
      WITH SYNONYMS ('lapses')
      COMMENT = 'Total number of lapse events.',
    policies.average_annual_premium AS AVG(policies.annual_premium)
      WITH SYNONYMS ('average premium', 'mean annual premium')
      COMMENT = 'Average annualized policy premium.'
  )
  COMMENT = 'Semantic view for Modern Insurance Platform performance analysis.'
  AI_SQL_GENERATION
    'Use event_month for time-based questions. Treat product_code as the line of business. Prefer metrics over raw facts when aggregating. Round monetary values to two decimal places.'
  AI_QUESTION_CATEGORIZATION
    'This view answers questions about policy counts, premium movement, new business, renewals, cancellations, lapses, claim volumes, and claims paid. Ask for clarification if the user asks for customer-level PII or an ambiguous time period.';

------------------------------------------------------------------------------
-- Grant the role used by analysts / Snowflake Intelligence users
------------------------------------------------------------------------------

GRANT REFERENCES, SELECT ON SEMANTIC VIEW insurance_performance TO ROLE ROLE_ANALYST;
GRANT USAGE ON WAREHOUSE MODERN_INSURANCE_PLATFORM_WH TO ROLE ROLE_ANALYST;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE ROLE_ANALYST;

------------------------------------------------------------------------------
-- Create the Agent object shown by Snowflake Intelligence
--
-- If the Snowflake Intelligence UI says "No agents available", it normally
-- means no Agent object has been created or granted to your current role.
------------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE ROLE_ANALYST;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE ROLE_ANALYST;
GRANT CREATE AGENT ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE ROLE_ANALYST;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.INSURANCE_PERFORMANCE_AGENT
  COMMENT = 'Snowflake Intelligence agent for Modern Insurance Platform performance analysis.'
  PROFILE = '{"display_name": "Insurance Performance", "avatar": "chart-bar", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 30
      tokens: 16000

  instructions:
    response: "Answer insurance performance questions clearly and concisely. Use charts when a trend or comparison would make the answer easier to understand."
    orchestration: "Use InsurancePerformanceAnalyst for questions about policies, premium movement, claims, quotes, new business, renewals, cancellations, lapses, products, or monthly trends."
    sample_questions:
      - question: "What was total net premium movement by product last month?"
      - question: "Show claims paid by product over time."
      - question: "Which product has the highest cancellation volume?"
      - question: "Compare new business and renewals by month."

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "InsurancePerformanceAnalyst"
        description: "Answers structured insurance performance questions using the insurance performance semantic view."
    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generates charts from tabular data when useful."

  tool_resources:
    InsurancePerformanceAnalyst:
      semantic_view: "PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE"
      execution_environment:
        type: "warehouse"
        warehouse: "MODERN_INSURANCE_PLATFORM_WH"
        query_timeout: 60
  $$;

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.INSURANCE_PERFORMANCE_AGENT TO ROLE ROLE_ANALYST;

------------------------------------------------------------------------------
-- Smoke tests
------------------------------------------------------------------------------

SHOW SEMANTIC VIEWS LIKE 'INSURANCE_PERFORMANCE' IN SCHEMA PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS;
SHOW SEMANTIC METRICS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE;
SHOW SEMANTIC DIMENSIONS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE;
SHOW AGENTS LIKE 'INSURANCE_PERFORMANCE_AGENT' IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;

------------------------------------------------------------------------------
-- Snowflake Intelligence setup in Snowsight / ai.snowflake.com
--
-- 1. Open Snowflake Intelligence.
-- 2. Switch to ROLE_ANALYST.
-- 3. Select the "Insurance Performance" agent.
-- 4. Suggested sample questions:
--      - What was total net premium movement by product last month?
--      - Show claims paid by product over time.
--      - Which product has the highest cancellation volume?
--      - Compare new business and renewals by month.
------------------------------------------------------------------------------
