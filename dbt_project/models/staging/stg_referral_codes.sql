-- Staging model: stg_referral_codes
-- Transforms referral codes data and adds processing timestamp.
-- Data Quality Fix: Cast id from float (1.0, 2.0) to integer (1, 2).

{{ config(materialized='table') }}

SELECT
    CAST(id AS INTEGER) AS id,
    referral_code,
    status,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('sql_server', 'referral_codes') }}