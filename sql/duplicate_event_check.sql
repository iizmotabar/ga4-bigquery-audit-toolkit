-- Catches events firing more than once within the same session, which inflates
-- conversion counts and skews funnel numbers. Common causes: a tag firing on both
-- a page load and a history change event, or duplicate GTM containers on one page.

WITH event_counts AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    COUNT(*) AS fire_count
  FROM `project.analytics_XXXXXXXX.events_*`
  WHERE event_name IN ('purchase', 'generate_lead', 'form_submit')
    AND _TABLE_SUFFIX BETWEEN '20250101' AND '20250131'
  GROUP BY user_pseudo_id, session_id, event_name, page_location
)

SELECT
  event_name,
  page_location,
  COUNT(*) AS sessions_with_duplicates,
  SUM(fire_count) - COUNT(*) AS extra_fires
FROM event_counts
WHERE fire_count > 1
GROUP BY event_name, page_location
ORDER BY extra_fires DESC;
