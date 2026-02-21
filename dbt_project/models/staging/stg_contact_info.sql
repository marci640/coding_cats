-- Staging model: stg_contact_info
-- Transforms customer contact information and adds processing timestamp.

{{ config(materialized='table') }}

SELECT
    id,
    phone,
    street,
    city,
    state,
    postal_code,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('sql_server', 'contact_info') }}