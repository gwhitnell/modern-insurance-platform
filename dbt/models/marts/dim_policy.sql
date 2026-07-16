with policies as (

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
    from {{ ref('stg_policies') }}

),

customers as (

    select
        customer_nk,
        customer_id
    from {{ ref('dim_customer') }}

)

select
    p.policy_id,
    c.customer_nk,
    p.customer_id,
    p.product_code,
    p.inception_date,
    p.expiry_date,
    p.policy_status,
    p.annual_premium,
    p.source_system,
    p.ingested_at
from policies p
left join customers c
  on p.customer_id = c.customer_id