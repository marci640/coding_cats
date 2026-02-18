# Sprint 02 Archive — coding_cats_sprint_02
**Closed:** 2026-02-17
**Version:** 1.1.0
**Branch:** `sprint_02`

## Business Rules Applied

- **Filter:** Exclude any users where `signup_date` is before 2025-01-01
- **Transformation:** Add `CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at` to all output rows

## Permanent Rules Promoted to CLAUDE.md

- Profile schema is `main` (default). Seeds load into `main` schema.
- Seed CSV lives in `dbt_project/seeds/`. `dbt_project.yml` uses default `seed-paths: ["seeds"]`.
- Staging models reference seeds with `ref('raw_data')` — no `sources.yml` needed for DuckDB seeds.

## Artifacts Produced

| File | Action |
|------|--------|
| `dbt_project/models/staging/schema.yml` | Updated — added `processed_at`, `accepted_values`, enriched descriptions |
| `dbt_project/models/staging/stg_raw_data.sql` | Updated — switched to `ref()`, added `WHERE` filter |
| `dbt_project/dbt_project.yml` | Updated — added explicit seed column types |
| `dags/dbt_csv_dag.py` | Carried over — no changes required |
| `agents/01_architect.md` | Refactored — reads `SPRINT_REQUIREMENTS.md`, produces `schema.yml` as contract |
| `agents/02_transformer.md` | Refactored — reads `schema.yml` as sole source of truth |
| `agents/archived_sprints/sprint_01/` | Created — sprint 01 agent files archived |
| `dbt_project/models/staging/sources.yml` | Deleted — replaced by `ref()` pattern |

## Test Results

- `dbt test`: **10/10 PASS, 0 failures**
- Tests: `unique` + `not_null` on `id` and `email`, `not_null` on all columns, `accepted_values` on `plan_type`

## Auditor Findings

1 finding detected and fixed: Jinja `ref()` was incorrectly used inside a `schema.yml` model description string — removed.
