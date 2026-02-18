-- Intermediate model: int_plan_features
-- Joins stg_plans to stg_benefit_features on benefit.
-- Enriches plans with feature flags and total feature count.

{{ config(materialized='table') }}

SELECT
    p.plan_type,
    p.amount,
    p.benefit,
    bf.email_support,
    bf.live_chat,
    bf.phone_support,
    bf.api_access,
    bf.custom_integrations,
    bf.sla_guarantee,
    bf.total_features,
    p.processed_at
FROM {{ ref('stg_plans') }} AS p
INNER JOIN {{ ref('stg_benefit_features') }} AS bf
    ON p.benefit = bf.benefit
