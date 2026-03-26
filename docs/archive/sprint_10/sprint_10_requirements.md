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
- **A1 — Volatility Penalty Severity:** Apply volatility penalty of `10` points to `health_momentum_score` when `usage_volatility_index > 0.35`; otherwise `0`.
- **A2 — Usage Momentum Thresholds:** `pct_change = (usage_hours_last_30d - usage_hours_prev_30d) / NULLIF(usage_hours_prev_30d, 0)`. `rising` if `>= 0.10`, `declining` if `<= -0.10`, `stable` otherwise.
- **A3 — Volatility Index Calculation:** `LEAST(1.00, COALESCE(STDDEV_SAMP / AVG(monthly_usage_hours), 0))` over last 3 monthly periods; bounded 0–1.
- **A4 — Health Momentum Score Formula:** `health_momentum_score = CLAMP_0_100(health_score + momentum_adjustment - volatility_penalty)`. Momentum adjustment: `+8` rising, `0` stable, `-8` declining.
- **A5 — Churn Risk Score Composition:** `churn_risk_score = CLAMP_0_100((100 - health_momentum_score) * 0.55 + momentum_risk * 0.20 + support_risk * 0.15 + (100 - referral_quality_score) * 0.10)`. `momentum_risk`: rising=20, stable=50, declining=80. `support_risk`: TRUE=80, FALSE=20.
- **A6 — Intervention Tier Thresholds:** `immediate` if `churn_risk_score >= 75`; `near_term` if `45–74`; `monitor` if `< 45`.
- **A7 — Action Window Days:** `immediate` → 3 days; `near_term` → 10 days; `monitor` → 21 days.
- **A8 — Reason Code Precedence:** `declining_usage` > `high_support_load` > `weak_referral` (if `referral_quality_score < 40`) > `low_health` (fallback).
- **A9 — Owner Queue Assignment:** `enterprise` + `immediate`/`near_term` → `csm_enterprise`; non-enterprise + `immediate` → `retention_specialist`; `near_term` → `csm_general`; `monitor` → `lifecycle_nurture`.
- **A10 — Enterprise Completeness Standard:** If enterprise and `usage_momentum`, `usage_volatility_index`, or `referral_quality_score` is null → force `intervention_tier = 'near_term'` and `reason = 'incomplete_enterprise_profile'`.

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
