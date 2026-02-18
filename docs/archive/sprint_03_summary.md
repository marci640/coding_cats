# Sprint 03 Archive — coding_cats_sprint_03
**Closed:** 2026-02-18
**Version:** 1.3.0
**Branch:** `sprint_03`

## Business Rules Applied

- **New seed:** `plans.csv` (3 rows: basic, premium, enterprise) staged as `stg_plans`
- **Rename:** `signup_date` → `registered_at` in `int_raw_data`
- **Computed column:** `'ACTIVE' AS status` (literal) added to `int_raw_data`
- **Computed column:** `amount * 0.20 AS discount_amount` added to `int_plans`
- **Join:** `int_plans` joins `stg_raw_data` to `stg_plans` on `plan_type` via `INNER JOIN`
- **Existing filter carried forward:** `WHERE signup_date >= '2025-01-01'` on `stg_raw_data`

## Permanent Rules Promoted to CLAUDE.md

None — no rules marked as Global/Permanent in this sprint.

## Artifacts Produced

| File | Action |
|------|--------|
| `dbt_project/seeds/plans.csv` | Created — plan reference data (3 rows) |
| `dbt_project/dbt_project.yml` | Updated — added `plans` seed column types |
| `dbt_project/models/staging/schema.yml` | Updated — added `stg_plans` contract (4 columns, 6 tests) |
| `dbt_project/models/staging/stg_plans.sql` | Created — stages plans seed with `processed_at` |
| `dbt_project/models/intermediate/schema.yml` | Created — contracts for `int_raw_data` (12 tests) and `int_plans` (11 tests) |
| `dbt_project/models/intermediate/int_raw_data.sql` | Created — renames `signup_date`, adds `status` |
| `dbt_project/models/intermediate/int_plans.sql` | Created — joins on `plan_type`, adds `discount_amount` |
| `dags/dbt_csv_dag.py` | Updated — removed `--models` filter to run all models |

## Test Results

- `dbt test`: **38/38 PASS, 0 failures, 0 warnings**
- PKs tested: `stg_raw_data.id`, `stg_plans.plan_type`, `int_raw_data.id`, `int_plans.id`
- Coverage: `unique` + `not_null` on all PKs, `not_null` on all columns, `accepted_values` on `plan_type` and `status`

## Auditor Findings

No findings — all contract, business, and standards checks passed on first attempt.
