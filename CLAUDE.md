# Project Charter: Coding Cats Pipeline
**Goal:** Demo DBT pipeline creation using Claude, orchestrated by a Technical PM. 

## Technical Standards
- **SQL Style:** Snowflake/DuckDB dialect; Uppercase keywords.
- **dbt Version:** 1.7+
- **Airflow:** Local execution using `Astro CLI` or `docker-compose`.
- **Testing:** Every model MUST have a `unique` and `not_null` test on the primary key.

## DuckDB Local Setup Notes
- **Profile schema:** `main` (default). When a seed uses `+schema: raw`, DuckDB creates schema `main_raw`.
- **Seed path:** CSV lives in `data/` (project root), so `dbt_project.yml` uses `seed-paths: ["../data"]`.
- **Source schema:** Must match the actual DuckDB schema (e.g., `main_raw`), not the logical name.
- **Prerequisites:** `pip install dbt-core dbt-duckdb` 

## Definition of Done (DoD)
1. CSV is loaded into a staging table.
2. Transformation adds `CAST(CURRENT_TIMESTAMP AS TIMESTAMP) AS processed_at`.
3. `dbt test` passes with 0 errors.
4. Airflow DAG triggers the dbt run successfully.

## Zero-Tolerance Rules (Invariants)
- **Naming:** ALL database objects MUST be `snake_case`. No `CamelCase`, no `PascalCase`.
- **Handoffs:** The Transformer is FORBIDDEN from writing SQL until the Architect has produced a `schema.yml`.
- **Validation:** No PR can be generated unless the Auditor confirms 100% test coverage for Primary Keys.

## System of Record (State Management)
- **Primary Logic:** `/.ai/SPRINT_REQUIREMENTS.md` (Updated by TPM)
- **Technical Spec:** `models/staging/schema.yml` (Updated by Architect)
- **Implementation:** `models/staging/*.sql` (Updated by Transformer)

## Agentic Handoff Protocol
1. **ARCHITECT:** Reads Requirements -> Generates `schema.yml`. 
   *IF schema.yml is missing documentation tags, the task is FAIL.*
2. **TRANSFORMER:** Reads `schema.yml` -> Generates SQL. 
   *SQL column names MUST match schema.yml exactly.*
3. **AUDITOR:** Executes `dbt compile` -> Compares SQL output against `schema.yml`.
   *Any mismatch triggers an automatic REJECT and REWORK loop.*