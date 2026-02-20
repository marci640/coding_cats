{{ config(materialized='table') }}

SELECT
    *
FROM {{ source('sql_server', 'diagnosis') }}
