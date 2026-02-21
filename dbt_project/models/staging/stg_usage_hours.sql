-- Staging model: stg_usage_hours
-- Transforms usage hours data and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    month,
    year,
    hours_used,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('sql_server', 'usage_hours') }}