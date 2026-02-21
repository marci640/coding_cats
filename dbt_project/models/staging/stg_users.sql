-- Staging model: stg_users
-- Transforms raw customer data, filters pre-2025 signups, and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    name,
    email,
    signup_date,
    plan_type,
    amount,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ ref('raw_data') }}
WHERE signup_date >= '2025-01-01'
