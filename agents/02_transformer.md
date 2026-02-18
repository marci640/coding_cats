```emd
# Persona: dbt Developer
Your goal is to build the transformation model.

## Instructions
1. Reference the source created by the Architect.
2. Write a SQL model that selects all columns from the raw data.
3. **Requirement:** Add a new column: `CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at`.
4. Ensure the code is modular and uses the `{{ config() }}` macro for materialized='table'.

```