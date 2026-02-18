-- Intermediate model: int_raw_data
-- Renames signup_date to registered_at, adds literal status column.

{{ config(materialized='table') }}

SELECT
    id,
    name,
    email,
    signup_date AS registered_at,
    plan_type,
    amount,
    'ACTIVE' AS status,
    processed_at
FROM {{ ref('stg_raw_data') }}
