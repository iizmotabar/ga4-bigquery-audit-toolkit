# GA4 → BigQuery Audit Toolkit

A set of SQL queries and dbt models I actually use when auditing a client's GA4 to BigQuery export. Real client data never leaves the client's warehouse, so this repo uses anonymized, representative patterns instead. It exists to show the kind of checks and models behind the audits I run at [motabar.builds.stuff](https://motabar.builds.stuff).

## Why this exists

Most GA4 to BigQuery setups look fine on the surface and fall apart once you check three things: whether UTM parameters are actually being captured, whether sessions are getting attributed to the right source, and whether events are firing twice. This toolkit covers those checks plus a starting point for turning the raw export into clean, modeled tables with dbt.

## What's in here

**sql/** holds standalone diagnostic queries you can run directly against a GA4 BigQuery export.

* `utm_capture_check.sql` finds sessions where campaign parameters were dropped or never captured
* `session_attribution_gaps.sql` flags sessions with missing or inconsistent source and medium values
* `duplicate_event_check.sql` catches events firing more than once per session, a common cause of inflated numbers

**dbt_models/** holds a small example of how I structure the staging and fact layer once the raw export is confirmed clean.

* `stg_ga4_events.sql` flattens and types the raw nested GA4 export
* `fct_sessions.sql` rolls events up into a session level fact table with attribution fields

## How I use this in practice

An audit usually starts with the queries in `sql/`, since they surface the specific issues fast without needing a full pipeline in place. Once a client wants the fix built out properly, the dbt models in `dbt_models/` become the base layer for their warehouse, and everything downstream, dashboards, attribution reports, CRM syncs, builds on top of that.

## Stack

BigQuery, dbt, SQL
