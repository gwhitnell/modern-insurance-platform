with claims as (

    select
        claim_id,
        policy_id,
        loss_date,
        reported_date,
        claim_status,
        paid_amount,
        source_system,
        ingested_at
    from {{ ref('stg_claims') }}

),

policies as (

    select
        policy_id,
        customer_nk
    from {{ ref('dim_policy') }}

)

select
    c.claim_id,
    c.policy_id,
    p.customer_nk,
    c.loss_date,
    c.reported_date,
    c.claim_status,
    c.paid_amount,
    c.source_system,
    c.ingested_at
from claims c
left join policies p
  on c.policy_id = p.policy_id