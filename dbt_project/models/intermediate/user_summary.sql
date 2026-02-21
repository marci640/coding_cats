-- Final model: user_summary
-- Comprehensive user analytics with enterprise flags and usage statistics.

{{ config(materialized='table') }}

SELECT
    id,
    name,
    email,
    plan_type,
    total_usage_hours,
    total_phone_calls,
    is_high_value_enterprise,
    CASE 
        WHEN plan_type = 'enterprise' THEN TRUE 
        ELSE FALSE 
    END AS is_enterprise,
    processed_at
FROM {{ ref('int_user_stats') }}