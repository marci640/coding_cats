## Sprint Requirements
<!-- Sprint version: 2.0.0 | Started: 2026-03-23 -->
**Sprint ID:** coding_cats_sprint_10
**Goal:** Deliver a retention intervention layer that combines customer health, trend momentum, and referral quality into prioritized outreach actions for weekly operations.

### Business Rules
- Preserve all prior Sprint 09 health logic as baseline behavior.
- Customers with declining engagement momentum should be prioritized for earlier intervention than equally scored customers with stable momentum.
- Enterprise customers should continue to meet stricter completeness expectations before receiving a final intervention tier.
- Referral quality remains directional: strong referral posture should improve intervention priority, weak referral posture should lower it.
- A volatility penalty should be applied when month-to-month usage behavior is unstable; exact severity is intentionally left for approved assumptions.
- Intervention output must remain explainable to operations via reason codes (not just opaque scores).

### Transformation Logic
- **Modify `int_user_stats`:**
	- Add `usage_hours_last_30d` (or nearest monthly proxy from available source grain).
	- Add `usage_hours_prev_30d` (or nearest previous monthly proxy).
	- Add `usage_momentum` as `rising`, `stable`, or `declining` derived from period-over-period change.
	- Add `usage_volatility_index` capturing variation across recent periods (bounded numeric).
- **Modify `int_customer_health`:**
	- Add `health_momentum_score` to reflect trend impact on current health.
	- Add `churn_risk_score` on a 0-100 scale using `health_score`, `usage_momentum`, `support_burden_flag`, and referral quality.
	- Add `intervention_tier` (e.g., immediate, near_term, monitor) based on `churn_risk_score` and strategic plan exceptions.
	- Add `intervention_reason` text/code describing the dominant driver of the assigned tier.
- **Create new intermediate model `int_retention_actions`:**
	- Source from `int_customer_health`.
	- Emit one row per customer with `id` as primary key.
	- Include recommended action fields: `action_priority`, `action_window_days`, `owner_queue`, `reason_code`, `processed_at`.
	- Derive `action_window_days` so higher-risk customers are contacted sooner.
- **Modify `user_summary`:**
	- Surface `churn_risk_score`, `intervention_tier`, `intervention_reason`, `usage_momentum`, and `action_window_days`.
	- Keep current primary key and legacy summary fields intact.
- **Data quality requirements:**
	- Every sprint-touched model must maintain PK tests (`unique` + `not_null`) on its primary key.
	- New categorical fields must have `accepted_values` tests.
	- Score fields must be non-null and bounded to documented ranges.

### New Models / Sources
- **New model:** `models/intermediate/int_retention_actions.sql`
- **Model updates required:**
	- `models/intermediate/int_user_stats.sql`
	- `models/intermediate/int_customer_health.sql`
	- `models/intermediate/user_summary.sql`
	- `models/intermediate/schema.yml`
- **Required upstream inputs for this sprint:**
	- `models/staging/stg_usage_hours.sql`
	- `models/staging/stg_phone_log.sql`
	- `models/staging/stg_referral_codes.sql`
	- `models/staging/stg_enterprise_accounts.sql`

### Execution Prerequisites
- Validate source-backed staging readiness before any full run:
	- `dbt run --select stg_usage_hours stg_phone_log stg_referral_codes stg_enterprise_accounts`
- Validate baseline health dependencies before new retention layer:
	- `dbt run --select int_plans int_user_stats int_customer_health`
- Do not proceed to full `dbt run`/`dbt test` if any prerequisite model fails to build.

### Technical Dependencies
- dbt project conventions and Snowflake/DuckDB SQL style remain required.
- Existing Airflow DAG (`dags/dbt_csv_dag.py`) must continue to execute seed → run → test successfully.
- No new Python package dependency is required for this sprint.

### Approved Assumptions
None yet.

### Acceptance Criteria
1. `int_retention_actions` exists, is documented in `schema.yml`, and has PK tests (`unique`, `not_null`) on `id`.
2. `int_user_stats` contains `usage_momentum` and `usage_volatility_index` with `accepted_values`/range validation as applicable.
3. `int_customer_health` contains `churn_risk_score`, `intervention_tier`, and `intervention_reason` with documented logic.
4. `user_summary` surfaces sprint-required intervention fields.
5. `dbt compile` succeeds with no schema/model mismatch.
6. `dbt test` passes with 0 errors for all sprint-touched models.
7. DAG syntax remains valid and the dbt chain is unchanged (seed → run → test).

### Permanent Rules (will be promoted to CLAUDE.md on sprint close)
- Intervention-facing categorical outputs must always include `accepted_values` tests and business definitions.