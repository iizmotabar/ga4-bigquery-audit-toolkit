-- Finds sessions where campaign traffic arrived but UTM parameters were not captured.
-- Common causes: redirect chains stripping query params, client side routing swallowing
-- the first pageview, or server side tagging dropping the parameters before they reach GA4.

WITH session_traffic AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') AS source,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium') AS medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS campaign,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page
  FROM `project.analytics_XXXXXXXX.events_*`
  WHERE event_name = 'page_view'
    AND _TABLE_SUFFIX BETWEEN '20250101' AND '20250131'
)

SELECT
  landing_page,
  COUNT(*) AS sessions_missing_campaign
FROM session_traffic
WHERE landing_page LIKE '%utm_campaign%'   -- the URL had a campaign param
  AND campaign IS NULL                     -- but GA4 never captured it
GROUP BY landing_page
ORDER BY sessions_missing_campaign DESC;
