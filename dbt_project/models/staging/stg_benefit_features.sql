-- Staging model: stg_benefit_features
-- Stages benefit feature flags and computes total_features count.

{{ config(materialized='table') }}

SELECT
    benefit,
    email_support,
    live_chat,
    phone_support,
    api_access,
    custom_integrations,
    sla_guarantee,
    email_support::INT + live_chat::INT + phone_support::INT + api_access::INT + custom_integrations::INT + sla_guarantee::INT AS total_features,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ ref('benefit_features') }}
