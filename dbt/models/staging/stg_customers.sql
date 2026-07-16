with source as (

    select
        trim(customer_id)      as customer_id,
        trim(first_name)       as first_name,
        trim(last_name)        as last_name,
        trim(dob)              as dob,
        trim(email)            as email,
        trim(created_at)       as created_at,
        trim(source_system)    as source_system,
        ingested_at
    from {{ source('raw', 'CUSTOMERS') }}

),

typed as (

    select
        customer_id,

        nullif(first_name, '') as first_name,
        nullif(last_name, '')  as last_name,

        coalesce(
            try_to_date(dob, 'YYYY-MM-DD'),
            try_to_date(dob, 'DD/MM/YYYY'),
            try_to_date(dob, 'YYYY/MM/DD'),
            try_to_date(dob, 'DD-MM-YYYY')
        ) as date_of_birth,

        nullif(lower(email), '') as email,

        coalesce(
            try_to_timestamp_tz(created_at),
            try_to_timestamp_ntz(created_at, 'YYYY-MM-DD HH24:MI:SS'),
            try_to_timestamp_ntz(created_at, 'YYYY/MM/DD HH24:MI'),
            try_to_timestamp_ntz(created_at, 'YYYY-MM-DD')
        ) as created_at_ts,

        nullif(source_system, '') as source_system,
        ingested_at

    from source

)

select
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    email,
    created_at_ts,
    source_system,
    ingested_at
from typed