-- Intermediate model: int_customer_health
-- Joins int_plans, int_user_stats, and referral data to compute health and churn risk contract fields.

{{ config(materialized='table') }}

WITH referral_scored AS (
    SELECT
        id,
        status AS referral_status,
        CAST(
            CASE status
                WHEN 'active' THEN 80.0
                WHEN 'inactive' THEN 40.0
                WHEN 'expired' THEN 10.0
                ELSE 50.0
            END AS DECIMAL(5,2)
        ) AS referral_quality_score_raw
    FROM {{ ref('stg_referral_codes') }}
),

base AS (
    SELECT
        ip.id,
        ip.name,
        ip.email,
        ip.plan_type,
        ip.amount,
        ip.plan_value_band,
        ip.plan_rank,
        ius.total_usage_hours,
        ius.usage_momentum,
        ius.usage_volatility_index,
        ius.total_phone_calls,
        ius.engagement_score,
        ius.support_burden_flag,
        ius.usage_recency_hint,
        rs.referral_status,
        rs.referral_quality_score_raw,
        COALESCE(rs.referral_quality_score_raw, 50.0) AS referral_quality_score,
        LEAST(100.0, GREATEST(0.0, ROUND(
            CASE ip.plan_value_band
                WHEN 'strategic' THEN 30.0
                WHEN 'premium' THEN 25.0
                WHEN 'growth' THEN 18.0
                ELSE 12.0
            END
            + ius.engagement_score * 0.45
            + COALESCE(rs.referral_quality_score_raw, 50.0) * 0.25
            - CASE WHEN ius.support_burden_flag THEN 15.0 ELSE 0.0 END,
            2
        ))) AS health_score
    FROM {{ ref('int_plans') }} ip
    INNER JOIN {{ ref('int_user_stats') }} ius
        ON ip.id = ius.id
    LEFT JOIN referral_scored rs
        ON ip.id = rs.id
),

scored AS (
    SELECT
        *,
        CASE
            WHEN usage_momentum = 'rising' THEN 8
            WHEN usage_momentum = 'declining' THEN -8
            ELSE 0
        END AS momentum_adjustment,
        CASE
            WHEN usage_volatility_index > 0.35 THEN 10
            ELSE 0
        END AS volatility_penalty
    FROM base
),

risked AS (
    SELECT
        *,
        LEAST(100.0, GREATEST(0.0, ROUND(health_score + momentum_adjustment - volatility_penalty, 2))) AS health_momentum_score,
        CASE
            WHEN usage_momentum = 'rising' THEN 20
            WHEN usage_momentum = 'declining' THEN 80
            ELSE 50
        END AS momentum_risk,
        CASE
            WHEN support_burden_flag THEN 80
            ELSE 20
        END AS support_risk
    FROM scored
),

final_scored AS (
    SELECT
        *,
        LEAST(
            100.0,
            GREATEST(
                0.0,
                ROUND(
                    (100 - health_momentum_score) * 0.55
                    + momentum_risk * 0.20
                    + support_risk * 0.15
                    + (100 - referral_quality_score) * 0.10,
                    2
                )
            )
        ) AS churn_risk_score
    FROM risked
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
    usage_momentum,
    usage_volatility_index,
    total_phone_calls,
    engagement_score,
    support_burden_flag,
    usage_recency_hint,
    referral_status,
    referral_quality_score,
    health_score,
    health_momentum_score,
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
    churn_risk_score,
    CASE
        WHEN plan_type = 'enterprise'
             AND (
                 usage_momentum IS NULL
                 OR usage_volatility_index IS NULL
                 OR referral_quality_score_raw IS NULL
             ) THEN 'near_term'
        WHEN churn_risk_score >= 75 THEN 'immediate'
        WHEN churn_risk_score >= 45 THEN 'near_term'
        ELSE 'monitor'
    END AS intervention_tier,
    CASE
        WHEN plan_type = 'enterprise'
             AND (
                 usage_momentum IS NULL
                 OR usage_volatility_index IS NULL
                 OR referral_quality_score_raw IS NULL
             ) THEN 'incomplete_enterprise_profile'
        WHEN usage_momentum = 'declining' THEN 'declining_usage'
        WHEN support_burden_flag THEN 'high_support_load'
        WHEN referral_quality_score < 40 THEN 'weak_referral'
        ELSE 'low_health'
    END AS intervention_reason,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM final_scored
