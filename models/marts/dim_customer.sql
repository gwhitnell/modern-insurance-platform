-- Dedupe strategy:
-- 1. Prefer email as natural key
-- 2. Fallback to customer_id
-- 3. Select most recent created_at_ts
-- 4. Tie-break using ingested_at

with base as (

    select
        customer_id,
        first_name,
        last_name,
        date_of_birth,
        email,
        created_at_ts,
        source_system,
        ingested_at,

        coalesce(email, customer_id) as customer_nk
    from {{ ref('stg_customers') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by customer_nk
            order by created_at_ts desc nulls last, ingested_at desc
        ) as rn
    from base

)

select
    customer_nk,
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    email,
    created_at_ts as created_at,
    source_system,
    ingested_at
from ranked
where rn = 1