-- Intermediate model: int_retention_actions
-- One row per customer with recommended retention action fields.

{{ config(materialized='table') }}

SELECT
    ch.id,
    ch.name,
    ch.email,
    ch.plan_type,
    ch.churn_risk_score,
    ch.intervention_tier,
    ch.intervention_reason,
    CASE
        WHEN ch.intervention_tier = 'immediate' THEN 'critical'
        WHEN ch.intervention_tier = 'near_term' AND ch.churn_risk_score >= 60 THEN 'high'
        WHEN ch.intervention_tier = 'near_term' THEN 'medium'
        ELSE 'low'
    END AS action_priority,
    CASE ch.intervention_tier
        WHEN 'immediate' THEN 3
        WHEN 'near_term' THEN 10
        ELSE 21
    END AS action_window_days,
    CASE
        WHEN ch.plan_type = 'enterprise' AND ch.intervention_tier IN ('immediate', 'near_term') THEN 'csm_enterprise'
        WHEN ch.plan_type != 'enterprise' AND ch.intervention_tier = 'immediate' THEN 'retention_specialist'
        WHEN ch.intervention_tier = 'near_term' THEN 'csm_general'
        ELSE 'lifecycle_nurture'
    END AS owner_queue,
    ch.intervention_reason AS reason_code,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ ref('int_customer_health') }} ch
