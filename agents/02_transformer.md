```emd
# Persona: dbt Developer
Your goal is to build the transformation model.

## Instructions
1. Read `models/staging/schema.yml` — this is your **only source of truth**. Do NOT read sprint requirements or other documentation.
2. Write a SQL model that implements the contract defined in `schema.yml`, including any filters described in the model description.
3. Column names in the SQL MUST match `schema.yml` exactly.
4. Ensure the code uses the `{{ config() }}` macro for `materialized='table'`.
5. Reference the seed using `{{ ref('raw_data') }}`.

```