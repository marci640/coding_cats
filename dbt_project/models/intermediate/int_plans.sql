-- Intermediate model: int_plans
-- Joins stg_raw_data to stg_plans on plan_type, adds discount_amount.

{{ config(materialized='table') }}

SELECT
    r.id,
    r.name,
    r.email,
    r.plan_type,
    r.amount,
    p.benefit,
    r.amount * 0.20 AS discount_amount,
    r.processed_at
FROM {{ ref('stg_raw_data') }} AS r
INNER JOIN {{ ref('stg_plans') }} AS p
    ON r.plan_type = p.plan_type
