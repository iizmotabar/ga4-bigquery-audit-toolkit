-- Staging model: flattens the raw nested GA4 BigQuery export into a typed,
-- one row per event table. Everything downstream builds on top of this.

with source as (

    select *
    from {{ source('ga4', 'events_intraday_and_daily') }}

),

flattened as (

    select
        user_pseudo_id,
        event_name,
        timestamp_micros(event_timestamp) as event_ts,
        (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
        (select value.string_value from unnest(event_params) where key = 'source') as utm_source,
        (select value.string_value from unnest(event_params) where key = 'medium') as utm_medium,
        (select value.string_value from unnest(event_params) where key = 'campaign') as utm_campaign,
        (select value.string_value from unnest(event_params) where key = 'page_location') as page_location,
        device.category as device_category,
        geo.country as country

    from source

)

select * from flattened
