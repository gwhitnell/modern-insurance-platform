{{ config(
    materialized='incremental',
    unique_key=['policy_id', 'event_month']
) }}

with events as (

    select
        policy_id,
        customer_nk,
        date_trunc('month', event_ts) as event_month,
        event_type,
        gross_premium_change
    from {{ ref('fct_business_events') }}

),

claims as (

    select
        policy_id,
        date_trunc('month', loss_date) as claim_month,
        count(*) as claim_count,
        sum(paid_amount) as total_paid
    from {{ ref('fct_claims') }}
    group by 1, 2

),

event_rollup as (

    select
        policy_id,
        customer_nk,
        event_month,

        count_if(event_type = 'quote')          as quote_count,
        count_if(event_type = 'new_business')   as new_business_count,
        count_if(event_type = 'mta')            as mta_count,
        count_if(event_type = 'renewal')        as renewal_count,
        count_if(event_type = 'cancellation')   as cancellation_count,
        count_if(event_type = 'lapse')          as lapse_count,

        sum(gross_premium_change) as net_premium_change

    from events
    group by 1, 2, 3

)

select *
from (

    select
        e.policy_id,
        e.customer_nk,
        e.event_month,

        e.quote_count,
        e.new_business_count,
        e.mta_count,
        e.renewal_count,
        e.cancellation_count,
        e.lapse_count,
        e.net_premium_change,

        coalesce(c.claim_count, 0) as claim_count,
        coalesce(c.total_paid, 0)  as total_paid

    from event_rollup e
    left join claims c
      on e.policy_id = c.policy_id
     and e.event_month = c.claim_month

) final

{% if is_incremental() %}
where event_month > (select max(event_month) from {{ this }})
{% endif %}