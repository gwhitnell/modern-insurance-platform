------------------------------------------------------------------------------
-- Snowflake Intelligence bootstrap
--
-- Run after:
--   1. Terraform has created PRD_MODERN_INSURANCE_PLATFORM.
--   2. PRD raw data has been seeded.
--   3. dbt has built the PRD marts into the ANALYTICS schema.
--
-- Purpose:
--   Creates Snowflake native semantic views that Cortex Analyst can use as
--   structured-data tools inside a Snowflake Intelligence Agent.
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

CREATE OR ALTER SEMANTIC VIEW customer_service_lookup
  TABLES (
    customers AS PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.DIM_CUSTOMER
      PRIMARY KEY (customer_nk)
      WITH SYNONYMS ('customers', 'customer records', 'customer dimension', 'policyholders')
      COMMENT = 'Demo customer records for customer service lookup, including verified customer details.',

    policies AS PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.DIM_POLICY
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('policies', 'insurance policies', 'policy records')
      COMMENT = 'Policy records linked to customers.',

    claims AS PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.FCT_CLAIMS
      PRIMARY KEY (claim_id)
      WITH SYNONYMS ('claims', 'insurance claims', 'claim records')
      COMMENT = 'Claim records linked to policies.'
  )
  RELATIONSHIPS (
    policies_to_customers AS
      policies (customer_nk) REFERENCES customers,
    claims_to_policies AS
      claims (policy_id) REFERENCES policies
  )
  FACTS (
    policies.annual_premium AS annual_premium
      COMMENT = 'Annualized policy premium.',
    claims.paid_amount AS paid_amount
      COMMENT = 'Amount paid on the claim.'
  )
  DIMENSIONS (
    customers.customer_nk AS customer_nk
      WITH SYNONYMS ('customer natural key', 'logical customer key')
      COMMENT = 'Derived natural key used to deduplicate customer records.',
    customers.customer_id AS customer_id
      WITH SYNONYMS ('customer number', 'customer reference')
      COMMENT = 'Source system customer identifier.',
    customers.first_name AS first_name
      WITH SYNONYMS ('forename', 'given name')
      COMMENT = 'Customer first name in the demo data.',
    customers.last_name AS last_name
      WITH SYNONYMS ('surname', 'family name')
      COMMENT = 'Customer last name in the demo data.',
    customers.date_of_birth AS date_of_birth
      WITH SYNONYMS ('dob', 'birth date')
      COMMENT = 'Customer date of birth.',
    customers.email AS email
      WITH SYNONYMS ('email address')
      COMMENT = 'Customer email address.',
    policies.policy_id AS policy_id
      WITH SYNONYMS ('policy number', 'policy reference')
      COMMENT = 'Unique policy identifier.',
    policies.product_code AS product_code
      WITH SYNONYMS ('product', 'line of business', 'insurance product')
      COMMENT = 'Insurance product code.',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('status', 'policy lifecycle status')
      COMMENT = 'Current policy lifecycle status.',
    policies.inception_date AS inception_date
      WITH SYNONYMS ('policy start date', 'start date')
      COMMENT = 'Policy inception date.',
    policies.expiry_date AS expiry_date
      WITH SYNONYMS ('policy end date', 'end date')
      COMMENT = 'Policy expiry date.',
    claims.claim_id AS claim_id
      WITH SYNONYMS ('claim number', 'claim reference')
      COMMENT = 'Unique claim identifier.',
    claims.loss_date AS loss_date
      COMMENT = 'Date of loss occurrence.',
    claims.reported_date AS reported_date
      COMMENT = 'Date the claim was reported.',
    claims.claim_status AS claim_status
      WITH SYNONYMS ('claim state')
      COMMENT = 'Current claim lifecycle status.'
  )
  METRICS (
    customers.customer_count AS COUNT(DISTINCT customers.customer_nk)
      WITH SYNONYMS ('number of customers', 'customers')
      COMMENT = 'Count of distinct customers.',
    policies.policy_count AS COUNT(DISTINCT policies.policy_id)
      WITH SYNONYMS ('number of policies', 'policies')
      COMMENT = 'Count of distinct policies.',
    claims.claim_count AS COUNT(DISTINCT claims.claim_id)
      WITH SYNONYMS ('number of claims', 'claims')
      COMMENT = 'Count of distinct claims.',
    claims.total_paid_amount AS SUM(claims.paid_amount)
      WITH SYNONYMS ('claims paid', 'paid claims', 'claim payments')
      COMMENT = 'Total amount paid on claims.'
  )
  COMMENT = 'Semantic view for customer service lookup across demo customers, policies, and claims.'
  AI_SQL_GENERATION
    'Use this view for customer service lookup questions over demo data. Return only the fields needed to answer the lookup. For broad name searches, limit results and include customer_id, first_name, last_name, policy_id, product_code, policy_status, claim_id, claim_status, and paid_amount when relevant. Use case-insensitive matching for names, email addresses, customer IDs, policy IDs, and claim IDs. Use LIMIT 100 by default and use a smaller limit when the user asks for one.'
  AI_QUESTION_CATEGORIZATION
    'This view answers customer service lookup questions about demo customers, policies, and claims by first name, last name, date of birth, email, customer ID, policy ID, or claim ID. It can answer prompts such as find customers called Ruby, find policy P100123, or show claim CL200126. If the user asks for unrelated real-world PII or a production identity lookup outside this demo dataset, say the model only supports the demo insurance data.';

------------------------------------------------------------------------------
-- Grant the role used by analysts / Snowflake Intelligence users
------------------------------------------------------------------------------

GRANT REFERENCES, SELECT ON SEMANTIC VIEW insurance_performance TO ROLE ROLE_ANALYST;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW customer_service_lookup TO ROLE ROLE_ANALYST;
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
    orchestration: "Use InsurancePerformanceAnalyst for questions about aggregate performance, premium movement, claims trends, quotes, new business, renewals, cancellations, lapses, products, or monthly trends. Use CustomerServiceAnalyst for customer service lookup questions about named demo customers, customer IDs, policy IDs, claim IDs, customer contact details, policy details, or individual claim records."
    sample_questions:
      - question: "What was total net premium movement by product last month?"
      - question: "Show claims paid by product over time."
      - question: "Which product has the highest cancellation volume?"
      - question: "Compare new business and renewals by month."
      - question: "Find customers called Ruby."
      - question: "Look up policy P100123."
      - question: "Show claim CL200126."

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "InsurancePerformanceAnalyst"
        description: "Answers structured insurance performance questions using the insurance performance semantic view."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CustomerServiceAnalyst"
        description: "Answers customer service lookup questions using demo customers, policies, and claims."
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
    CustomerServiceAnalyst:
      semantic_view: "PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.CUSTOMER_SERVICE_LOOKUP"
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
SHOW SEMANTIC VIEWS LIKE 'CUSTOMER_SERVICE_LOOKUP' IN SCHEMA PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS;
SHOW SEMANTIC METRICS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE;
SHOW SEMANTIC DIMENSIONS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.INSURANCE_PERFORMANCE;
SHOW SEMANTIC METRICS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.CUSTOMER_SERVICE_LOOKUP;
SHOW SEMANTIC DIMENSIONS IN PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.CUSTOMER_SERVICE_LOOKUP;
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
--      - Find customers called Ruby.
--      - Look up policy P100123.
--      - Show claim CL200126.
------------------------------------------------------------------------------
