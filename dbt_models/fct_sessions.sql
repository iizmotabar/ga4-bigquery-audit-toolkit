-- Fact model: rolls flattened events up into one row per session, with first touch
-- attribution and basic engagement signals. This is the table most reporting and
-- attribution work downstream should query instead of hitting raw events directly.

with events as (

    select *
    from {{ ref('stg_ga4_events') }}

),

session_first_touch as (

    select
        user_pseudo_id,
        session_id,
        min(event_ts) as session_start,
        max(event_ts) as session_end,
        array_agg(utm_source ignore nulls order by event_ts limit 1)[safe_offset(0)] as first_touch_source,
        array_agg(utm_medium ignore nulls order by event_ts limit 1)[safe_offset(0)] as first_touch_medium,
        array_agg(utm_campaign ignore nulls order by event_ts limit 1)[safe_offset(0)] as first_touch_campaign,
        countif(event_name = 'purchase') as purchase_count,
        countif(event_name = 'generate_lead') as lead_count,
        count(*) as total_events

    from events
    group by user_pseudo_id, session_id

)

select
    user_pseudo_id,
    session_id,
    session_start,
    session_end,
    timestamp_diff(session_end, session_start, second) as session_duration_seconds,
    first_touch_source,
    first_touch_medium,
    first_touch_campaign,
    purchase_count,
    lead_count,
    total_events

from session_first_touch
