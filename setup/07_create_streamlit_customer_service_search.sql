------------------------------------------------------------------------------
-- Create Streamlit in Snowflake app
--
-- Run after:
--   1. setup/06_streamlit_customer_service_search.sql has created the stage.
--   2. apps/customer_service_search.py has been uploaded to:
--      @PRD_MODERN_INSURANCE_PLATFORM.APP.STREAMLIT_STAGE/customer_service_search
------------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE MODERN_INSURANCE_PLATFORM_WH;
USE DATABASE PRD_MODERN_INSURANCE_PLATFORM;
USE SCHEMA APP;

CREATE OR REPLACE STREAMLIT CUSTOMER_SERVICE_SEARCH
  FROM @PRD_MODERN_INSURANCE_PLATFORM.APP.STREAMLIT_STAGE/customer_service_search
  MAIN_FILE = 'customer_service_search.py'
  QUERY_WAREHOUSE = MODERN_INSURANCE_PLATFORM_WH
  TITLE = 'Customer Service Search'
  COMMENT = 'Search customers, policies, and claims from Snowflake marts.';

GRANT USAGE ON STREAMLIT CUSTOMER_SERVICE_SEARCH TO ROLE ROLE_ANALYST;

------------------------------------------------------------------------------
-- Smoke tests
------------------------------------------------------------------------------

SHOW STREAMLITS LIKE 'CUSTOMER_SERVICE_SEARCH' IN SCHEMA PRD_MODERN_INSURANCE_PLATFORM.APP;

------------------------------------------------------------------------------
-- Open in Snowsight
--
-- 1. Switch to ROLE_ANALYST.
-- 2. Open Streamlit.
-- 3. Select "Customer Service Search".
------------------------------------------------------------------------------
