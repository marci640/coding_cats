# Sprint Summary: Coding Cats Pipeline

**Sprint Date:** February 14, 2026
**Status:** ✅ Complete

---

## Objective

Ingest `raw_data.csv` into a dbt staging model, add a `processed_at` timestamp column, define data quality tests, and orchestrate via an Airflow DAG.

---

## Data Source

| File | Rows | Columns |
|------|------|---------|
| `data/raw_data.csv` | 10 | `id`, `name`, `email`, `signup_date`, `plan_type`, `amount` |

---

## Artifacts Produced

| # | File | Description |
|---|------|-------------|
| 1 | `dbt_project/models/staging/sources.yml` | dbt source definition pointing to `raw.raw_data` |
| 2 | `dbt_project/models/staging/stg_raw_data.sql` | Staging model — selects all columns + adds `processed_at` |
| 3 | `dbt_project/models/staging/schema.yml` | Column-level tests (`unique`, `not_null`, `accepted_values`) |
| 4 | `dags/dbt_csv_dag.py` | Airflow DAG: `dbt seed → dbt run → dbt test` |

---

## Transformation Logic

```sql
SELECT
    id,
    name,
    email,
    signup_date,
    plan_type,
    amount,
    CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at
FROM {{ source('raw', 'raw_data') }}
```

- **SQL dialect:** Snowflake/DuckDB (uppercase keywords)
- **Materialization:** `table`
- **Timestamp:** `CURRENT_TIMESTAMP` per project charter

---

## Test Coverage

| Column | Tests |
|--------|-------|
| `id` | `unique`, `not_null` |
| `name` | `not_null` |
| `email` | `unique`, `not_null` |
| `signup_date` | `not_null` |
| `plan_type` | `not_null`, `accepted_values: [basic, premium, enterprise]` |
| `amount` | `not_null` |
| `processed_at` | `not_null` |

---

## Airflow DAG

| Property | Value |
|----------|-------|
| DAG ID | `dbt_csv_pipeline` |
| Schedule | `@daily` |
| Start Date | 2025-01-01 |
| Catchup | `False` |
| Operator | `BashOperator` |

**Task chain:** `dbt_seed` → `dbt_run` → `dbt_test`

---

## Execution Phases

| Phase | Agent | Status | Notes |
|-------|-------|--------|-------|
| 1 — Architect | `01_architect.md` | ✅ | Schema analysis, `sources.yml` created |
| 2 — Transformer | `02_transformer.md` | ✅ | Model + schema tests written |
| 3 — Auditor | `03_auditor.md` | ✅ | 3 findings detected, all fixed (see below) |
| 4 — DevOps | `04_devops.md` | ✅ | Airflow DAG created, syntax validated |

### Auditor Findings (Phase 3)

1. **CRITICAL** — `stg_raw_data.sql` used `SELECT *` without `processed_at` → Fixed: explicit column list + timestamp added.
2. **CRITICAL** — `schema.yml` missing → Fixed: created with full PK and column tests.
3. **WARNING** — `run_started_at` vs `CURRENT_TIMESTAMP` conflict → Resolved: `CURRENT_TIMESTAMP` per charter.

---

## Definition of Done

- [x] dbt model exists and adds `processed_at`
- [x] `dbt test` passes with 0 errors (10/10 PASS)
- [x] Airflow DAG file is syntactically correct Python
- [x] Sprint README generated (`sprint_readme.md`)

---

## Setup Prerequisites

To reproduce from scratch:

1. **Python packages:** `pip install dbt-core dbt-duckdb`
2. **Verify binary:** `dbt --version` should show `dbt-core`. Remove any `dbt-fusion` or `dbt` Cloud CLI that may shadow it.
3. **Seed path:** CSV lives in `data/` (project root). `dbt_project.yml` sets `seed-paths: ["../data"]`.
4. **Schema note:** DuckDB concatenates profile schema (`main`) + seed schema override (`raw`) → creates `main_raw`. The `sources.yml` must reference `main_raw`, not `raw`.

## Run Commands

```bash
cd dbt_project
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

## Remaining Next Steps

1. Deploy DAG to Airflow (Astro CLI or docker-compose).
