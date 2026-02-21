-- Staging model: stg_enterprise_accounts
-- Transforms enterprise account data and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    business_name,
    contract_value_usd,
    renewal_date,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('sql_server', 'enterprise_accounts') }}