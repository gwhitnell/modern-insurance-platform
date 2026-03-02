with source as (

    select
        trim(claim_id)       as claim_id,
        trim(policy_id)      as policy_id,
        trim(loss_date)      as loss_date,
        trim(reported_date)  as reported_date,
        trim(claim_status)   as claim_status,
        trim(paid_amount)    as paid_amount,
        trim(source_system)  as source_system,
        ingested_at
    from {{ source('raw', 'CLAIMS') }}

),

typed as (

    select
        claim_id,
        policy_id,

        coalesce(
            try_to_date(loss_date, 'YYYY-MM-DD'),
            try_to_date(loss_date, 'DD/MM/YYYY'),
            try_to_date(loss_date, 'YYYY/MM/DD'),
            try_to_date(loss_date, 'DD-MM-YYYY')
        ) as loss_date,

        coalesce(
            try_to_date(reported_date, 'YYYY-MM-DD'),
            try_to_date(reported_date, 'DD/MM/YYYY'),
            try_to_date(reported_date, 'YYYY/MM/DD'),
            try_to_date(reported_date, 'DD-MM-YYYY')
        ) as reported_date,

        nullif(upper(claim_status), '') as claim_status,

        try_to_decimal(
            nullif(regexp_replace(paid_amount, '[£,\\s]', ''), ''),
            12, 2
        ) as paid_amount,

        nullif(source_system, '') as source_system,
        ingested_at

    from source

)

select
    claim_id,
    policy_id,
    loss_date,
    reported_date,
    claim_status,
    paid_amount,
    source_system,
    ingested_at
from typed