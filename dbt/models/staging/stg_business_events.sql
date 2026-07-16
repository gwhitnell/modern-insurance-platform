with source as (

    select
        trim(event_id)             as event_id,
        trim(policy_id)            as policy_id,
        trim(event_ts)             as event_ts,
        trim(event_type)           as event_type,
        trim(channel)              as channel,
        trim(gross_premium_change) as gross_premium_change,
        trim(event_version)        as event_version,
        trim(source_system)        as source_system,
        ingested_at
    from {{ source('raw', 'BUSINESS_EVENTS') }}

),

typed as (

    select
        event_id,
        policy_id,

        -- timestamp parsing (mixed formats)
        coalesce(
            try_to_timestamp_tz(event_ts),
            try_to_timestamp_ntz(event_ts, 'YYYY-MM-DD HH24:MI'),
            try_to_timestamp_ntz(event_ts, 'YYYY/MM/DD HH24:MI'),
            try_to_timestamp_ntz(event_ts, 'DD/MM/YYYY HH24:MI')
        ) as event_ts,

        nullif(lower(event_type), '') as event_type,
        nullif(lower(channel), '') as channel,

        try_to_decimal(
            nullif(regexp_replace(gross_premium_change, '[£,\\s]', ''), ''),
            12, 2
        ) as gross_premium_change,

        try_to_number(nullif(event_version, '')) as event_version,

        nullif(source_system, '') as source_system,
        ingested_at

    from source

)

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
from typed