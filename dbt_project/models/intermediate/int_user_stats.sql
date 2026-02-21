-- Intermediate model: int_user_stats
-- Combines user data with usage hours, phone calls, and enterprise status.
-- Joins stg_users (base) with aggregated usage_hours, phone_log, and enterprise_accounts.

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

enterprise_high_value AS (
    SELECT 
        id,
        CASE 
            WHEN contract_value_usd > 60000 THEN TRUE 
            ELSE FALSE 
        END AS is_high_value_enterprise
    FROM {{ ref('stg_enterprise_accounts') }}
)

SELECT
    u.id,
    u.name,
    u.email,
    u.plan_type,
    COALESCE(ua.total_usage_hours, 0) AS total_usage_hours,
    COALESCE(pa.total_phone_calls, 0) AS total_phone_calls,
    COALESCE(ehv.is_high_value_enterprise, FALSE) AS is_high_value_enterprise,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ ref('stg_users') }} u
LEFT JOIN usage_aggregated ua ON u.id = ua.id
LEFT JOIN phone_aggregated pa ON u.id = pa.id  
LEFT JOIN enterprise_high_value ehv ON u.id = ehv.id