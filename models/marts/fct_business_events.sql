with events as (

    select
        event_id,
        policy_id,
        event_ts,
        event_type,
        channel,
        gross_premium_change,
        event_version,
        source_system,
        ingested_at
    from {{ ref('stg_business_events') }}

),

policies as (

    select
        policy_id,
        customer_nk
    from {{ ref('dim_policy') }}

)

select
    e.event_id,
    e.policy_id,
    p.customer_nk,
    e.event_ts,
    e.event_type,
    e.channel,
    e.gross_premium_change,
    e.event_version,
    e.source_system,
    e.ingested_at
from events e
left join policies p
  on e.policy_id = p.policy_id