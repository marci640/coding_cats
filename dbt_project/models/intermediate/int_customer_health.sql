-- Intermediate model: int_customer_health
-- Joins int_plans, int_user_stats, and stg_referral_codes to produce a unified health scoring contract.
-- Computes health_score, risk_band, and retention_priority.

{{ config(materialized='table') }}

WITH referral_scored AS (
    SELECT
        id,
        status AS referral_status,
        CAST(CASE status
            WHEN 'active'   THEN 20.0
            WHEN 'inactive' THEN 0.0
            WHEN 'expired'  THEN -10.0
            ELSE 0.0
        END AS DECIMAL(5,2)) AS referral_quality_score
    FROM {{ ref('stg_referral_codes') }}
),

health_computed AS (
    SELECT
        ip.id,
        ip.name,
        ip.email,
        ip.plan_type,
        ip.amount,
        ip.plan_value_band,
        ip.plan_rank,
        ius.total_usage_hours,
        ius.total_phone_calls,
        ius.engagement_score,
        ius.support_burden_flag,
        ius.usage_recency_hint,
        rs.referral_status,
        COALESCE(rs.referral_quality_score, 0.0) AS referral_quality_score,
        LEAST(100.0, GREATEST(0.0, ROUND(
            ip.plan_rank * 10.0
            + ius.engagement_score * 0.5
            + CASE
                WHEN ius.support_burden_flag AND ip.plan_value_band != 'strategic' THEN -10.0
                ELSE 0.0
              END
            + COALESCE(rs.referral_quality_score, 0.0),
        2))) AS health_score
    FROM {{ ref('int_plans') }} ip
    INNER JOIN {{ ref('int_user_stats') }} ius
        ON ip.id = ius.id
    LEFT JOIN referral_scored rs
        ON ip.id = rs.id
)

SELECT
    id,
    name,
    email,
    plan_type,
    amount,
    plan_value_band,
    plan_rank,
    total_usage_hours,
    total_phone_calls,
    engagement_score,
    support_burden_flag,
    usage_recency_hint,
    referral_status,
    referral_quality_score,
    health_score,
    CASE
        WHEN health_score >= 70 THEN 'low'
        WHEN health_score >= 40 THEN 'medium'
        ELSE 'high'
    END AS risk_band,
    CASE
        WHEN health_score >= 70 THEN 'p3'
        WHEN health_score >= 40 THEN 'p2'
        ELSE 'p1'
    END AS retention_priority,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM health_computed
