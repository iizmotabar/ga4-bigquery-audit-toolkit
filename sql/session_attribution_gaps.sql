-- Flags sessions where source or medium is missing or inconsistent across the events
-- that belong to the same session. This usually points to attribution being overwritten
-- mid session, often by a second script firing on a later page.

WITH session_events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') AS source,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium') AS medium,
    event_timestamp
  FROM `project.analytics_XXXXXXXX.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20250101' AND '20250131'
),

session_summary AS (
  SELECT
    user_pseudo_id,
    session_id,
    COUNT(DISTINCT source) AS distinct_sources,
    COUNT(DISTINCT medium) AS distinct_mediums,
    COUNTIF(source IS NULL) AS null_source_events
  FROM session_events
  GROUP BY user_pseudo_id, session_id
)

SELECT *
FROM session_summary
WHERE distinct_sources > 1
   OR distinct_mediums > 1
   OR null_source_events > 0
ORDER BY distinct_sources DESC, distinct_mediums DESC;
