# Sprint 08 Archive — int_plans High-Value Flags
**Closed:** 2026-03-19
**Version:** 1.8.0
**Branch:** `sprint_08`

## Business Rules Applied
- Keep signup filter behavior via upstream staging model.
- Set `is_high_value = TRUE` when `plan_type IN ('premium', 'enterprise')`, else `FALSE`.
- Set `days_since_signup = CURRENT_DATE - signup_date` as integer.

## Permanent Rules Promoted to CLAUDE.md
- none

## Artifacts Produced
- Modified: `dbt_project/models/intermediate/int_plans.sql`
- Modified: `dbt_project/models/intermediate/schema.yml`

## Test Results
- `dbt seed --select raw_data plans`: PASS
- `dbt run --select stg_users stg_plans int_plans`: PASS
- `dbt test --select int_plans`: PASS (16/16 tests)

## Auditor Findings
- No findings
