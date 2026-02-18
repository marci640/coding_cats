-- Staging model: stg_plans
-- Stages plan reference data and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    plan_type,
    amount,
    benefit,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ ref('plans') }}
