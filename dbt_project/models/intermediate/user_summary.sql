-- Final model: user_summary
-- Comprehensive user analytics sourced from int_customer_health.
-- Surfaces health_score, risk_band, retention_priority, plan_value_band, and support_burden_flag.

{{ config(materialized='table') }}

SELECT
    ch.id,
    ch.name,
    ch.email,
    ch.plan_type,
    ch.plan_value_band,
    ch.total_usage_hours,
    ch.total_phone_calls,
    ch.support_burden_flag,
    ch.usage_momentum,
    COALESCE(ius.is_high_value_enterprise, FALSE) AS is_high_value_enterprise,
    ch.health_score,
    ch.churn_risk_score,
    ch.risk_band,
    ch.retention_priority,
    ch.intervention_tier,
    ch.intervention_reason,
    ra.action_window_days,
    CASE
        WHEN ch.plan_type = 'enterprise' THEN TRUE
        ELSE FALSE
    END AS is_enterprise,
    ch.processed_at
FROM {{ ref('int_customer_health') }} ch
LEFT JOIN {{ ref('int_user_stats') }} ius
    ON ch.id = ius.id
LEFT JOIN {{ ref('int_retention_actions') }} ra
    ON ch.id = ra.id