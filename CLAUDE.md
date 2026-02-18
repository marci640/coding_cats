# Project Charter: Coding Cats Pipeline
**Goal:** Ingest `raw_data.csv`, add a `processed_at` timestamp, and orchestrate via Airflow.

## Technical Standards
- **SQL Style:** Snowflake/DuckDB dialect; Uppercase keywords.
- **dbt Version:** 1.7+
- **Airflow:** Local execution using `Astro CLI` or `docker-compose`.
- **Testing:** Every model MUST have a `unique` and `not_null` test on the primary key.

## DuckDB Local Setup Notes
- **Profile schema:** `main` (default). When a seed uses `+schema: raw`, DuckDB creates schema `main_raw`.
- **Seed path:** CSV lives in `data/` (project root), so `dbt_project.yml` uses `seed-paths: ["../data"]`.
- **Source schema:** Must match the actual DuckDB schema (e.g., `main_raw`), not the logical name.
- **Prerequisites:** `pip install dbt-core dbt-duckdb` — ensure no `dbt-fusion` or `dbt` Cloud CLI shadows the binary.

## Definition of Done (DoD)
1. CSV is loaded into a staging table.
2. Transformation adds `CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at`.
3. `dbt test` passes with 0 errors.
4. Airflow DAG triggers the dbt run successfully.
