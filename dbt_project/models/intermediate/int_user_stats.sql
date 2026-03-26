-- Intermediate model: int_user_stats
-- Combines user data with usage hours, phone calls, and enterprise status.
-- Adds usage momentum and volatility contract fields for downstream churn scoring.

{{ config(materialized='table') }}

WITH usage_monthly AS (
    SELECT
        id,
        MAKE_DATE(year, month, 1) AS usage_month,
        SUM(hours_used) AS monthly_usage_hours
    FROM {{ ref('stg_usage_hours') }}
    GROUP BY id, MAKE_DATE(year, month, 1)
),

latest_month AS (
    SELECT MAX(usage_month) AS latest_usage_month
    FROM usage_monthly
),

usage_aggregated AS (
    SELECT
        um.id,
        SUM(um.monthly_usage_hours) AS total_usage_hours,
        MAX(um.usage_month) AS last_usage_date,
        COALESCE(
            MAX(CASE WHEN um.usage_month = lm.latest_usage_month THEN um.monthly_usage_hours END),
            0
        ) AS usage_hours_last_30d,
        COALESCE(
            MAX(CASE WHEN um.usage_month = lm.latest_usage_month - INTERVAL '1 month' THEN um.monthly_usage_hours END),
            0
        ) AS usage_hours_prev_30d,
        LEAST(
            1.00,
            COALESCE(
                STDDEV_SAMP(
                    CASE
                        WHEN um.usage_month BETWEEN lm.latest_usage_month - INTERVAL '2 month' AND lm.latest_usage_month
                        THEN um.monthly_usage_hours
                    END
                )
                /
                NULLIF(
                    AVG(
                        CASE
                            WHEN um.usage_month BETWEEN lm.latest_usage_month - INTERVAL '2 month' AND lm.latest_usage_month
                            THEN um.monthly_usage_hours
                        END
                    ),
                    0
                ),
                0
            )
        ) AS usage_volatility_index
    FROM usage_monthly um
    CROSS JOIN latest_month lm
    GROUP BY um.id
),

phone_aggregated AS (
    SELECT
        id,
        COUNT(*) AS total_phone_calls,
        CAST(MAX(call_timestamp) AS DATE) AS last_call_date
    FROM {{ ref('stg_phone_log') }}
    GROUP BY id
),

enterprise_high_value AS (
    SELECT
        id,
        CASE
            WHEN contract_value_usd > 60000 THEN TRUE
            ELSE FALSE
        END AS is_high_value_enterprise
    FROM {{ ref('stg_enterprise_accounts') }}
),

base AS (
    SELECT
        u.id,
        u.name,
        u.email,
        u.plan_type,
        COALESCE(ua.total_usage_hours, 0) AS total_usage_hours,
        COALESCE(ua.usage_hours_last_30d, 0) AS usage_hours_last_30d,
        COALESCE(ua.usage_hours_prev_30d, 0) AS usage_hours_prev_30d,
        COALESCE(ua.usage_volatility_index, 0) AS usage_volatility_index,
        COALESCE(pa.total_phone_calls, 0) AS total_phone_calls,
        COALESCE(
            GREATEST(pa.last_call_date, ua.last_usage_date),
            pa.last_call_date,
            ua.last_usage_date
        ) AS most_recent_activity,
        COALESCE(ehv.is_high_value_enterprise, FALSE) AS is_high_value_enterprise
    FROM {{ ref('stg_users') }} u
    LEFT JOIN usage_aggregated ua ON u.id = ua.id
    LEFT JOIN phone_aggregated pa ON u.id = pa.id
    LEFT JOIN enterprise_high_value ehv ON u.id = ehv.id
)

SELECT
    id,
    name,
    email,
    plan_type,
    ROUND(total_usage_hours, 2) AS total_usage_hours,
    ROUND(usage_hours_last_30d, 2) AS usage_hours_last_30d,
    ROUND(usage_hours_prev_30d, 2) AS usage_hours_prev_30d,
    CASE
        WHEN usage_hours_prev_30d = 0 AND usage_hours_last_30d > 0 THEN 'rising'
        WHEN usage_hours_prev_30d = 0 THEN 'stable'
        WHEN (usage_hours_last_30d - usage_hours_prev_30d) / NULLIF(usage_hours_prev_30d, 0) >= 0.10 THEN 'rising'
        WHEN (usage_hours_last_30d - usage_hours_prev_30d) / NULLIF(usage_hours_prev_30d, 0) <= -0.10 THEN 'declining'
        ELSE 'stable'
    END AS usage_momentum,
    ROUND(usage_volatility_index, 2) AS usage_volatility_index,
    total_phone_calls,
    LEAST(100.0, GREATEST(0.0, ROUND(total_usage_hours * 1.5 + total_phone_calls * 2.0, 2))) AS engagement_score,
    total_phone_calls >= 2 AS support_burden_flag,
    CASE
        WHEN most_recent_activity IS NULL THEN 'none'
        WHEN DATEDIFF('day', most_recent_activity, CURRENT_DATE) <= 30 THEN 'current'
        WHEN DATEDIFF('day', most_recent_activity, CURRENT_DATE) <= 90 THEN 'recent'
        WHEN DATEDIFF('day', most_recent_activity, CURRENT_DATE) <= 365 THEN 'stale'
        ELSE 'none'
    END AS usage_recency_hint,
    is_high_value_enterprise,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM base