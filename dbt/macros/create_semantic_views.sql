{#
  Snowflake native semantic views for Cortex Analyst / Snowflake Intelligence.

  These macros deliberately resolve every physical table through ref(), so a
  run-operation uses the database and schemas associated with the selected dbt
  target instead of embedding DEV or PRD object names.
#}

{% macro _create_semantic_view(view_name, ddl) %}
  {% if execute %}
    {% do run_query(ddl) %}
    {% do log('Created or altered Snowflake semantic view ' ~ target.database ~ '.ANALYTICS.' ~ view_name, info=true) %}
  {% endif %}
{% endmacro %}


{% macro create_claims_semantic_view() %}
  {% set claims = ref('fct_claims') %}
  {% set policies = ref('dim_policy') %}
  {% set semantic_view = api.Relation.create(
      database=target.database,
      schema=claims.schema,
      identifier='claims_semantic_view'
  ) %}

  {% set ddl %}
CREATE OR ALTER SEMANTIC VIEW {{ semantic_view }}
  TABLES (
    claims AS {{ claims }}
      PRIMARY KEY (claim_id)
      WITH SYNONYMS ('claims', 'insurance claims', 'claim records')
      COMMENT = 'One current record per insurance claim, including paid-to-date value and reporting lag.',
    policies AS {{ policies }}
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('policies', 'insurance policies', 'policy dimension')
      COMMENT = 'Policy attributes used to segment claims.'
  )
  RELATIONSHIPS (
    claims_to_policies AS claims (policy_id) REFERENCES policies
  )
  FACTS (
    claims.paid_amount AS paid_amount
      COMMENT = 'Paid-to-date claim value; this is not incurred loss or reserve.',
    claims.reporting_lag_days AS reporting_lag_days
      COMMENT = 'Whole-day interval between loss and initial report.'
  )
  DIMENSIONS (
    claims.loss_date AS loss_date
      WITH SYNONYMS ('date of loss', 'incident date')
      COMMENT = 'Date on which the insured loss occurred.',
    claims.reported_date AS reported_date
      WITH SYNONYMS ('notification date', 'claim report date')
      COMMENT = 'Date on which the claim was first reported.',
    claims.claim_status AS claim_status
      WITH SYNONYMS ('claim state', 'status')
      COMMENT = 'Current claim lifecycle status.',
    claims.source_system AS source_system
      COMMENT = 'Source system that supplied the claim.',
    policies.product_code AS product_code
      WITH SYNONYMS ('product', 'line of business', 'insurance product')
      COMMENT = 'Insurance product code.',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('policy state')
      COMMENT = 'Current policy lifecycle status.'
  )
  METRICS (
    claims.total_claims AS COUNT(DISTINCT claims.claim_id)
      WITH SYNONYMS ('claim count', 'number of claims')
      COMMENT = 'Count of distinct claims.',
    claims.total_paid AS SUM(claims.paid_amount)
      WITH SYNONYMS ('claims paid', 'claim payments')
      COMMENT = 'Total paid-to-date claim value.',
    claims.open_claims AS COUNT(DISTINCT CASE WHEN claims.claim_status = 'OPEN' THEN claims.claim_id END)
      WITH SYNONYMS ('open claim count')
      COMMENT = 'Count of distinct claims whose current status is open.',
    claims.closed_claims AS COUNT(DISTINCT CASE WHEN claims.claim_status = 'CLOSED' THEN claims.claim_id END)
      WITH SYNONYMS ('closed claim count')
      COMMENT = 'Count of distinct claims whose current status is closed.',
    claims.average_reporting_lag_days AS AVG(claims.reporting_lag_days)
      WITH SYNONYMS ('average reporting delay', 'mean reporting lag')
      COMMENT = 'Mean whole-day interval between loss and initial report.',
    claims.average_paid_per_claim AS SUM(claims.paid_amount) / NULLIF(COUNT(DISTINCT claims.claim_id), 0)
      WITH SYNONYMS ('average claim payment', 'mean paid per claim')
      COMMENT = 'Paid-to-date value divided by distinct claim count.',
    claims.closure_rate AS COUNT(DISTINCT CASE WHEN claims.claim_status = 'CLOSED' THEN claims.claim_id END)
        / NULLIF(COUNT(DISTINCT claims.claim_id), 0)
      WITH SYNONYMS ('claim closure percentage', 'closed claim rate')
      COMMENT = 'Share of claims whose current lifecycle status is closed.'
  )
  COMMENT = 'Claims semantic view for Cortex Analyst, aligned with the dbt claims semantic model.'
  AI_SQL_GENERATION
    'Prefer defined metrics when aggregating. Treat paid_amount as paid-to-date, not incurred loss or reserve. Use loss_date as the default time dimension unless the question explicitly asks about reporting. Round monetary values to two decimal places and closure_rate to four decimal places.'
  AI_QUESTION_CATEGORIZATION
    'This view answers questions about claim counts, open and closed claims, paid-to-date values, reporting lag, claim status, product, policy status, source system, and loss or reporting dates.'
  {% endset %}

  {% do _create_semantic_view('CLAIMS_SEMANTIC_VIEW', ddl) %}
{% endmacro %}


{% macro create_insurance_performance_semantic_view() %}
  {% set policy_monthly = ref('fct_policy_monthly') %}
  {% set policies = ref('dim_policy') %}
  {% set semantic_view = api.Relation.create(
      database=target.database,
      schema=policy_monthly.schema,
      identifier='insurance_performance'
  ) %}

  {% set ddl %}
CREATE OR ALTER SEMANTIC VIEW {{ semantic_view }}
  TABLES (
    policy_monthly AS {{ policy_monthly }}
      PRIMARY KEY (policy_id, event_month)
      WITH SYNONYMS ('monthly policy performance', 'policy month rollup', 'insurance performance')
      COMMENT = 'Monthly policy performance rollup with business event and claims metrics.',
    policies AS {{ policies }}
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('policies', 'insurance policies', 'policy dimension')
      COMMENT = 'Policy attributes including product, status, premium, and lifecycle dates.'
  )
  RELATIONSHIPS (
    policy_monthly_to_policies AS policy_monthly (policy_id) REFERENCES policies
  )
  FACTS (
    policy_monthly.net_premium_change AS net_premium_change COMMENT = 'Premium movement during the month.',
    policy_monthly.claim_count AS claim_count COMMENT = 'Number of claims in the month.',
    policy_monthly.total_paid AS total_paid COMMENT = 'Total claims paid in the month.',
    policy_monthly.quote_count AS quote_count COMMENT = 'Number of quotes in the month.',
    policy_monthly.new_business_count AS new_business_count COMMENT = 'Number of new business events in the month.',
    policy_monthly.renewal_count AS renewal_count COMMENT = 'Number of renewal events in the month.',
    policy_monthly.cancellation_count AS cancellation_count COMMENT = 'Number of cancellation events in the month.',
    policy_monthly.lapse_count AS lapse_count COMMENT = 'Number of lapse events in the month.',
    policies.annual_premium AS annual_premium COMMENT = 'Annualized premium amount for a policy.'
  )
  DIMENSIONS (
    policy_monthly.event_month AS event_month
      WITH SYNONYMS ('month', 'calendar month', 'reporting month') COMMENT = 'Calendar month for the policy rollup.',
    policies.product_code AS product_code
      WITH SYNONYMS ('product', 'line of business', 'insurance product') COMMENT = 'Insurance product code.',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('status', 'policy lifecycle status') COMMENT = 'Current policy lifecycle status.',
    policies.source_system AS source_system COMMENT = 'Source system that produced the policy record.'
  )
  METRICS (
    policy_monthly.policy_count AS COUNT(DISTINCT policy_monthly.policy_id)
      WITH SYNONYMS ('number of policies', 'policies') COMMENT = 'Count of distinct policies.',
    policy_monthly.total_net_premium_change AS SUM(policy_monthly.net_premium_change)
      WITH SYNONYMS ('premium movement', 'net premium movement', 'premium change') COMMENT = 'Total net premium movement.',
    policy_monthly.total_claims AS SUM(policy_monthly.claim_count)
      WITH SYNONYMS ('claims', 'claim volume') COMMENT = 'Total number of claims.',
    policy_monthly.total_claims_paid AS SUM(policy_monthly.total_paid)
      WITH SYNONYMS ('claims paid', 'paid claims', 'claim payments') COMMENT = 'Total amount paid on claims.',
    policy_monthly.total_quotes AS SUM(policy_monthly.quote_count)
      WITH SYNONYMS ('quotes', 'quote volume') COMMENT = 'Total number of quote events.',
    policy_monthly.total_new_business AS SUM(policy_monthly.new_business_count)
      WITH SYNONYMS ('new business', 'new policies') COMMENT = 'Total number of new business events.',
    policy_monthly.total_renewals AS SUM(policy_monthly.renewal_count)
      WITH SYNONYMS ('renewals') COMMENT = 'Total number of renewal events.',
    policy_monthly.total_cancellations AS SUM(policy_monthly.cancellation_count)
      WITH SYNONYMS ('cancellations') COMMENT = 'Total number of cancellation events.',
    policy_monthly.total_lapses AS SUM(policy_monthly.lapse_count)
      WITH SYNONYMS ('lapses') COMMENT = 'Total number of lapse events.',
    policies.average_annual_premium AS AVG(policies.annual_premium)
      WITH SYNONYMS ('average premium', 'mean annual premium') COMMENT = 'Average annualized policy premium.'
  )
  COMMENT = 'Semantic view for Modern Insurance Platform performance analysis.'
  AI_SQL_GENERATION
    'Use event_month for time-based questions. Treat product_code as the line of business. Prefer metrics over raw facts when aggregating. Round monetary values to two decimal places.'
  AI_QUESTION_CATEGORIZATION
    'This view answers questions about policy counts, premium movement, new business, renewals, cancellations, lapses, claim volumes, and claims paid. Ask for clarification if the user asks for customer-level PII or an ambiguous time period.'
  {% endset %}

  {% do _create_semantic_view('INSURANCE_PERFORMANCE', ddl) %}
{% endmacro %}


{% macro create_customer_service_lookup_semantic_view() %}
  {% set customers = ref('dim_customer') %}
  {% set policies = ref('dim_policy') %}
  {% set claims = ref('fct_claims') %}
  {% set semantic_view = api.Relation.create(
      database=target.database,
      schema=customers.schema,
      identifier='customer_service_lookup'
  ) %}

  {% set ddl %}
CREATE OR ALTER SEMANTIC VIEW {{ semantic_view }}
  TABLES (
    customers AS {{ customers }}
      PRIMARY KEY (customer_nk)
      WITH SYNONYMS ('customers', 'customer records', 'customer dimension', 'policyholders')
      COMMENT = 'Demo customer records for customer service lookup, including verified customer details.',
    policies AS {{ policies }}
      PRIMARY KEY (policy_id)
      WITH SYNONYMS ('policies', 'insurance policies', 'policy records')
      COMMENT = 'Policy records linked to customers.',
    claims AS {{ claims }}
      PRIMARY KEY (claim_id)
      WITH SYNONYMS ('claims', 'insurance claims', 'claim records')
      COMMENT = 'Claim records linked to policies.'
  )
  RELATIONSHIPS (
    policies_to_customers AS policies (customer_nk) REFERENCES customers,
    claims_to_policies AS claims (policy_id) REFERENCES policies
  )
  FACTS (
    policies.annual_premium AS annual_premium COMMENT = 'Annualized policy premium.',
    claims.paid_amount AS paid_amount COMMENT = 'Paid-to-date amount on the claim.'
  )
  DIMENSIONS (
    customers.customer_nk AS customer_nk
      WITH SYNONYMS ('customer natural key', 'logical customer key') COMMENT = 'Derived natural key used to deduplicate customer records.',
    customers.customer_id AS customer_id
      WITH SYNONYMS ('customer number', 'customer reference') COMMENT = 'Source system customer identifier.',
    customers.first_name AS first_name
      WITH SYNONYMS ('forename', 'given name') COMMENT = 'Customer first name in the demo data.',
    customers.last_name AS last_name
      WITH SYNONYMS ('surname', 'family name') COMMENT = 'Customer last name in the demo data.',
    customers.date_of_birth AS date_of_birth
      WITH SYNONYMS ('dob', 'birth date') COMMENT = 'Customer date of birth.',
    customers.email AS email WITH SYNONYMS ('email address') COMMENT = 'Customer email address.',
    policies.policy_id AS policy_id
      WITH SYNONYMS ('policy number', 'policy reference') COMMENT = 'Unique policy identifier.',
    policies.product_code AS product_code
      WITH SYNONYMS ('product', 'line of business', 'insurance product') COMMENT = 'Insurance product code.',
    policies.policy_status AS policy_status
      WITH SYNONYMS ('status', 'policy lifecycle status') COMMENT = 'Current policy lifecycle status.',
    policies.inception_date AS inception_date
      WITH SYNONYMS ('policy start date', 'start date') COMMENT = 'Policy inception date.',
    policies.expiry_date AS expiry_date
      WITH SYNONYMS ('policy end date', 'end date') COMMENT = 'Policy expiry date.',
    claims.claim_id AS claim_id
      WITH SYNONYMS ('claim number', 'claim reference') COMMENT = 'Unique claim identifier.',
    claims.loss_date AS loss_date COMMENT = 'Date of loss occurrence.',
    claims.reported_date AS reported_date COMMENT = 'Date the claim was reported.',
    claims.claim_status AS claim_status
      WITH SYNONYMS ('claim state') COMMENT = 'Current claim lifecycle status.'
  )
  METRICS (
    customers.customer_count AS COUNT(DISTINCT customers.customer_nk)
      WITH SYNONYMS ('number of customers', 'customers') COMMENT = 'Count of distinct customers.',
    policies.policy_count AS COUNT(DISTINCT policies.policy_id)
      WITH SYNONYMS ('number of policies', 'policies') COMMENT = 'Count of distinct policies.',
    claims.claim_count AS COUNT(DISTINCT claims.claim_id)
      WITH SYNONYMS ('number of claims', 'claims') COMMENT = 'Count of distinct claims.',
    claims.total_paid_amount AS SUM(claims.paid_amount)
      WITH SYNONYMS ('claims paid', 'paid claims', 'claim payments') COMMENT = 'Total amount paid on claims.'
  )
  COMMENT = 'Semantic view for customer service lookup across demo customers, policies, and claims.'
  AI_SQL_GENERATION
    'Use this view for customer service lookup questions over demo data. Return only the fields needed to answer the lookup. For broad name searches, limit results. Use case-insensitive matching for names, email addresses, customer IDs, policy IDs, and claim IDs. Use LIMIT 100 by default and use a smaller limit when requested.'
  AI_QUESTION_CATEGORIZATION
    'This view answers customer service lookup questions about demo customers, policies, and claims by first name, last name, date of birth, email, customer ID, policy ID, or claim ID. If the user asks for unrelated real-world PII or a production identity lookup outside this demo dataset, say the model only supports the demo insurance data.'
  {% endset %}

  {% do _create_semantic_view('CUSTOMER_SERVICE_LOOKUP', ddl) %}
{% endmacro %}


{% macro create_semantic_views() %}
  {% do create_claims_semantic_view() %}
  {% do create_insurance_performance_semantic_view() %}
  {% do create_customer_service_lookup_semantic_view() %}
{% endmacro %}
