------------------------------------------------------------------------------
-- Streamlit in Snowflake bootstrap
--
-- Run after:
--   1. Terraform has created PRD_MODERN_INSURANCE_PLATFORM.
--   2. PRD raw data has been seeded.
--   3. dbt has built the PRD marts into the ANALYTICS schema.
--
-- Purpose:
--   Creates the schema and stage needed before uploading the Streamlit app
--   source file.
------------------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE MODERN_INSURANCE_PLATFORM_WH;
USE DATABASE PRD_MODERN_INSURANCE_PLATFORM;

------------------------------------------------------------------------------
-- App schema and stage
------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS APP
  COMMENT = 'Snowflake-native apps for Modern Insurance Platform.';

CREATE STAGE IF NOT EXISTS APP.STREAMLIT_STAGE
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Source files for Streamlit in Snowflake apps.';

GRANT USAGE ON DATABASE PRD_MODERN_INSURANCE_PLATFORM TO ROLE ROLE_ANALYST;
GRANT USAGE ON SCHEMA PRD_MODERN_INSURANCE_PLATFORM.APP TO ROLE ROLE_ANALYST;
GRANT USAGE ON WAREHOUSE MODERN_INSURANCE_PLATFORM_WH TO ROLE ROLE_ANALYST;

------------------------------------------------------------------------------
-- Next: upload the app file
--
-- Snowsight option:
--   1. Open Data > Databases > PRD_MODERN_INSURANCE_PLATFORM > APP > Stages.
--   2. Open STREAMLIT_STAGE.
--   3. Upload:
--        apps/customer_service_search.py
--      into folder:
--        customer_service_search
--
-- SnowSQL / Snowflake CLI option from the repo root:
--   PUT file://apps/customer_service_search.py
--     @PRD_MODERN_INSURANCE_PLATFORM.APP.STREAMLIT_STAGE/customer_service_search
--     AUTO_COMPRESS = FALSE
--     OVERWRITE = TRUE;
--
-- Then run:
--   setup/07_create_streamlit_customer_service_search.sql
------------------------------------------------------------------------------
