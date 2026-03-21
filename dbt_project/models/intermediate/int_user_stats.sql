-- Intermediate model: int_user_stats
-- Combines user data with usage hours, phone calls, and enterprise status.
-- Joins stg_users (base) with aggregated usage_hours, phone_log, and enterprise_accounts.
-- Adds engagement_score, support_burden_flag, and usage_recency_hint.

{{ config(materialized='table') }}

WITH usage_aggregated AS (
    SELECT 
        id,
        SUM(hours_used) AS total_usage_hours
    FROM {{ ref('stg_usage_hours') }}
    GROUP BY id
),

phone_aggregated AS (
    SELECT 
        id,
        COUNT(*) AS total_phone_calls
    FROM {{ ref('stg_phone_log') }}
    GROUP BY id
),

phone_recency AS (
    SELECT
        id,
        CAST(MAX(call_timestamp) AS DATE) AS last_call_date
    FROM {{ ref('stg_phone_log') }}
    GROUP BY id
),

usage_recency AS (
    SELECT
        id,
        MAX(MAKE_DATE(year, month, 1)) AS last_usage_date
    FROM {{ ref('stg_usage_hours') }}
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
            COALESCE(pa.total_phone_calls, 0) AS total_phone_calls,
            COALESCE(
                GREATEST(pr.last_call_date, ur.last_usage_date),
                pr.last_call_date,
                ur.last_usage_date
            ) AS most_recent_activity,
            COALESCE(ehv.is_high_value_enterprise, FALSE) AS is_high_value_enterprise
        FROM {{ ref('stg_users') }} u
        LEFT JOIN usage_aggregated ua ON u.id = ua.id
        LEFT JOIN phone_aggregated pa ON u.id = pa.id
        LEFT JOIN phone_recency pr ON u.id = pr.id
        LEFT JOIN usage_recency ur ON u.id = ur.id
        LEFT JOIN enterprise_high_value ehv ON u.id = ehv.id
    )

    SELECT
        id,
        name,
        email,
        plan_type,
        total_usage_hours,
        total_phone_calls,
        LEAST(100.0, GREATEST(0.0,
            ROUND(total_usage_hours * 1.5 + total_phone_calls * 2.0, 2)
        )) AS engagement_score,
        total_phone_calls >= 2 AS support_burden_flag,
        CASE
            WHEN most_recent_activity IS NULL THEN 'none'
            WHEN datediff('day', most_recent_activity, CURRENT_DATE) <= 30 THEN 'current'
            WHEN datediff('day', most_recent_activity, CURRENT_DATE) <= 90 THEN 'recent'
            WHEN datediff('day', most_recent_activity, CURRENT_DATE) <= 365 THEN 'stale'
            ELSE 'none'
        END AS usage_recency_hint,
        is_high_value_enterprise,
        CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
    FROM base