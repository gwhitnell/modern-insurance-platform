------------------------------------------------------------------------------
--   Macro: generate_schema_name

--   Purpose:
--     Controls how dbt determines the final schema name for models.

--   Why we override:
--     By default, dbt may concatenate target.schema and custom schema.
--     We want strict schema control:
--       - staging → CLEAN
--       - marts   → ANALYTICS

--   Behaviour:
--     - If model defines +schema, use it directly.
--     - Otherwise, fall back to target.schema.

--   Author: Gareth Whitnell
--   Project: Modern Insurance Platform
------------------------------------------------------------------------------ 

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name }}
    {%- endif -%}

{%- endmacro %}