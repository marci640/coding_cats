## Sprint Requirements
<!-- Sprint version: 1.9.0 | Started: 2026-03-19 -->
**Sprint ID:** coding_cats_sprint_09
**Goal:** Deliver a production-ready customer health and monetization layer by combining plan value, engagement, support burden, and referral quality into a unified risk-scoring output.

### Business Rules
- Continue enforcing all prior rules from Sprint 07 and Sprint 08 (`price_group`, `is_high_value`, `days_since_signup`) while expanding to cross-model scoring.
- Create a customer-level `health_score` and `risk_band` intended for weekly operations review.
- Customers with stronger engagement should generally rank better than similar customers with weak engagement.
- Heavy support users should be penalized unless they are on sufficiently valuable plans.
- Referral quality should influence score direction, but exact weight can be tuned if needed.
- Enterprise users should follow stricter quality expectations for data completeness.
- Exclusions should remove obviously non-actionable records (exact exclusion boundary intentionally left open for implementation assumptions).

### Transformation Logic
- **Modify `int_plans`:**
	- Add `plan_value_band` derived from `amount` and plan metadata.
	- Add `plan_rank` (numeric ordering) for downstream scoring joins.
	- Keep existing columns and existing filter behavior intact unless conflicts are discovered.
- **Modify `int_user_stats`:**
	- Add `engagement_score` using `total_usage_hours` and `total_phone_calls`.
	- Add `support_burden_flag` to indicate users with unusually high support activity.
	- Add `usage_recency_hint` using available temporal fields where practical.
- **Create new intermediate model `int_customer_health`:**
	- Join `int_plans`, `int_user_stats`, and referral information.
	- Compute `health_score` as a weighted combination of plan value, engagement, support burden, and referral quality.
	- Compute `risk_band` with at least three levels (`low`, `medium`, `high`) and include one additional optional level if justified.
	- Compute `retention_priority` to support outreach sequencing.
	- Include `processed_at` as `CAST(CURRENT_TIMESTAMP AS TIMESTAMP)`.
- **Create/update final model `user_summary`:**
	- Surface `health_score`, `risk_band`, `retention_priority`, `plan_value_band`, and `support_burden_flag`.
	- Preserve existing primary key and baseline dimensions.
- **Data quality requirements:**
	- Every model touched in this sprint must have primary key tests (`unique` + `not_null`) in schema definitions.
	- New categorical columns must include `accepted_values` tests where domain is explicit.
	- Score columns must be non-null and bounded to a documented range.

### New Models / Sources
- **New model:** `models/intermediate/int_customer_health.sql`
- **Required upstream staging source:** `models/staging/stg_usage_hours.sql` must be available and populated for Sprint 09 execution.
- **Schema updates required:**
	- `models/intermediate/schema.yml`
	- `models/staging/schema.yml` (only if new upstream fields are required)
- **Potential new seed:** optional mapping seed for score weights and/or risk thresholds (implement only if required for maintainability).
- External SQL Server source backing `stg_usage_hours` is mandatory for Sprint 09 run/test validation.

### Technical Dependencies
- dbt 1.7+ project conventions remain required.
- SQL dialect must remain Snowflake/DuckDB compatible with uppercase SQL keywords.
- Airflow DAG (`dags/dbt_csv_dag.py`) should continue running dbt seed/run/test successfully after model changes.
- Source connectivity for `usage_hours` must be operational before Phase 3 (Auditor) validation.
- No net-new Python package is required unless a lightweight utility for validation is explicitly needed.

### Approved Assumptions
- **A1 — `plan_value_band` thresholds:** classify `amount < 30` as `entry`, `amount >= 30 AND amount < 100` as `growth`, `amount >= 100 AND amount <= 200` as `premium`, and `amount > 200` as `strategic`.
- **A2 — `plan_rank` mapping:** assign `basic = 1`, `premium = 2`, and `enterprise = 3` for downstream ordering and scoring.
- **A3 — `engagement_score` shape:** compute a bounded numeric score on a `0` to `100` scale using `total_usage_hours` and `total_phone_calls`, with usage contributing more heavily than support interactions.
- **A4 — `support_burden_flag` threshold:** mark `TRUE` when `total_phone_calls >= 2`; otherwise `FALSE`.
- **A5 — `usage_recency_hint` buckets:** derive recency from the most recent observed activity date available from `stg_phone_log.call_timestamp` and `stg_usage_hours` month/year using `current`, `recent`, `stale`, and `none` buckets.
- **A6 — referral quality input:** use `stg_referral_codes.status` as the sole referral-quality input and treat missing referral records as neutral.
- **A7 — referral quality scoring:** map referral status to score contribution as `active = 20`, `inactive = 0`, `expired = -10`, `missing = 0`.
- **A8 — valuable-plan exemption:** interpret "sufficiently valuable plans" as `plan_value_band = 'strategic'`, meaning those customers are exempt from the support-burden penalty.
- **A9 — `health_score` composition:** compute `health_score` on a `0` to `100` scale using weighted plan value, engagement, support burden, and referral quality, with support burden acting as a negative adjustment.
- **A10 — `risk_band` thresholds:** use exactly three levels: `low` for `health_score >= 70`, `medium` for `health_score >= 40 AND < 70`, and `high` for `health_score < 40`.
- **A11 — `retention_priority` mapping:** use `p1` for `risk_band = 'high'`, `p2` for `risk_band = 'medium'`, and `p3` for `risk_band = 'low'`.

### Acceptance Criteria
1. `int_customer_health` is built and documented in `schema.yml` with complete column docs.
2. `health_score`, `risk_band`, and `retention_priority` are available in final `user_summary` output.
3. All touched models pass `dbt test` with 0 errors, including PK tests (`unique`, `not_null`).
4. `dbt compile` succeeds with no schema/model mismatch.
5. Airflow DAG triggers dbt workflow successfully end-to-end for Sprint 09 scope.

### Permanent Rules (promoted to CLAUDE.md on sprint close)
- If score thresholds are ambiguous, they must be explicitly captured as approved assumptions before SQL merge.
- Any risk classification column must have `accepted_values` tests and documented business definitions.
