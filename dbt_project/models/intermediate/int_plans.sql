-- Intermediate model: int_plans
-- Joins stg_users to stg_plans on plan_type, adds discount_amount and customer_tier.
-- Filter: Excludes rows where discount_amount is 0 or NULL.

{{ config(materialized='table') }}

SELECT
    r.id,
    r.name,
    r.email,
    r.plan_type,
    r.amount,
    p.benefit,
    r.amount * 0.20 AS discount_amount,
    CASE WHEN r.amount >= 100 THEN 'high_value' ELSE 'standard' END AS customer_tier,
    CASE
        WHEN r.amount < 30 THEN 'less than 30'
        WHEN r.amount > 200 THEN 'greater than 200'
        ELSE 'standard'
    END AS price_group,
    r.processed_at
FROM {{ ref('stg_users') }} AS r
INNER JOIN {{ ref('stg_plans') }} AS p
    ON r.plan_type = p.plan_type
WHERE r.amount * 0.20 > 0
    AND r.amount * 0.20 IS NOT NULL
