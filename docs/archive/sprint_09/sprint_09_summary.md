# Sprint 09 Archive — Customer Health Scoring Layer
**Closed:** 2026-03-21
**Version:** 1.9.0
**Branch:** `sprint_09`

## Business Rules Applied
- Customers with stronger engagement rank better than similar customers with weak engagement
- Heavy support users (total_phone_calls >= 2) incur a health score penalty unless on a `strategic` plan
- Referral quality influences score direction: `active = +20`, `inactive = 0`, `expired = -10`, `missing = 0`
- Enterprise users follow stricter quality expectations for data completeness
- `plan_value_band` segmentation: `entry` (< 30), `growth` (30–99.99), `premium` (100–200), `strategic` (> 200)
- `plan_rank` numeric ordering: `basic = 1`, `premium = 2`, `enterprise = 3`
- `engagement_score`: bounded 0–100, derived from `total_usage_hours * 1.5 + total_phone_calls * 2.0`
- `risk_band`: `low` (health_score >= 70), `medium` (40–69), `high` (< 40)
- `retention_priority`: `p1` (high risk), `p2` (medium risk), `p3` (low risk)

## Permanent Rules Promoted to CLAUDE.md
- If score thresholds are ambiguous, they must be explicitly captured as approved assumptions before SQL merge.
- Any risk classification column must have `accepted_values` tests and documented business definitions.

## Artifacts Produced

| File | Change |
|------|--------|
| `dbt_project/models/intermediate/int_customer_health.sql` | Created — unified health scoring model |
| `dbt_project/models/intermediate/int_plans.sql` | Modified — added `plan_value_band`, `plan_rank` |
| `dbt_project/models/intermediate/int_user_stats.sql` | Modified — added `engagement_score`, `support_burden_flag`, `usage_recency_hint` |
| `dbt_project/models/intermediate/user_summary.sql` | Modified — sourced from `int_customer_health`, added health fields |
| `dbt_project/models/intermediate/schema.yml` | Modified — added contracts for all new columns and `int_customer_health` |
| `.ai/ACTIVE_ASSUMPTIONS.md` | Created (temporary) — 11 TPM-approved assumptions |
| `.ai/sprint_ledger.json` | Updated — status transitions, artifact list |
| `CLAUDE.md` | Updated — 2 permanent rules promoted, Default Preflight Safety Gate added |
| `.ai/SPRINT_REQUIREMENTS_TEMPLATE.md` | Updated — Execution Prerequisites section added |

## Test Results
- **77 / 77 tests passed — 0 failures**
- All Sprint 09 models covered: `int_plans`, `int_user_stats`, `int_customer_health`, `user_summary`
- Primary key tests (`unique` + `not_null`) pass on all models
- `accepted_values` tests pass for `plan_value_band`, `plan_rank`, `risk_band`, `retention_priority`, `usage_recency_hint`

## Auditor Findings
- `int_user_stats`: CTE syntax error (missing comma before `base` CTE) — detected and fixed during Phase 3.
- `stg_enterprise_accounts` staging table not materialized before first intermediate run — resolved by explicitly running all staging prerequisites before intermediate models. Upstream readiness rule added to `CLAUDE.md` and sprint template.
- No schema/column mismatches between SQL output and `schema.yml` contract.
