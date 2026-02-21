-- Staging model: stg_phone_log
-- Transforms phone call log data and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    call_timestamp,
    direction,
    reason,
    agent_id,
    duration_seconds,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('sql_server', 'phone_log') }}