with source as (

    select
        trim(policy_id)        as policy_id,
        trim(customer_id)      as customer_id,
        trim(product_code)     as product_code,
        trim(inception_date)   as inception_date,
        trim(expiry_date)      as expiry_date,
        trim(status)           as status,
        trim(annual_premium)   as annual_premium,
        trim(source_system)    as source_system,
        ingested_at
    from {{ source('raw', 'POLICIES') }}

),

typed as (

    select
        policy_id,
        customer_id,

        nullif(upper(product_code), '') as product_code,

        coalesce(
            try_to_date(inception_date, 'YYYY-MM-DD'),
            try_to_date(inception_date, 'DD/MM/YYYY'),
            try_to_date(inception_date, 'YYYY/MM/DD'),
            try_to_date(inception_date, 'DD-MM-YYYY')
        ) as inception_date,

        coalesce(
            try_to_date(expiry_date, 'YYYY-MM-DD'),
            try_to_date(expiry_date, 'DD/MM/YYYY'),
            try_to_date(expiry_date, 'YYYY/MM/DD'),
            try_to_date(expiry_date, 'DD-MM-YYYY')
        ) as expiry_date,

        nullif(upper(status), '') as policy_status,

        -- premium cleaning: remove £, commas, and spaces then cast
        try_to_decimal(
            nullif(regexp_replace(annual_premium, '[£,\\s]', ''), ''),
            12, 2
        ) as annual_premium,

        nullif(source_system, '') as source_system,
        ingested_at

    from source

)

select
    policy_id,
    customer_id,
    product_code,
    inception_date,
    expiry_date,
    policy_status,
    annual_premium,
    source_system,
    ingested_at
from typed