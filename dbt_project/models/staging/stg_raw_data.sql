-- Staging model: stg_raw_data
-- Transforms raw customer data and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    name,
    email,
    signup_date,
    plan_type,
    amount,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('raw', 'raw_data') }}
