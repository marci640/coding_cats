# Sprint 10 Archive — Retention Intervention Layer
**Closed:** 2026-03-25
**Version:** 1.12.0
**Branch:** `sprint_10`

## Business Rules Applied
- Baseline Sprint 09 health logic preserved unchanged.
- Usage momentum classification (rising/stable/declining) based on ±10% month-over-month change (A2).
- Usage volatility index calculated as coefficient of variation over last 3 months, bounded 0–1 (A3).
- Volatility penalty of 10 pts applied to health_momentum_score when index > 0.35 (A1).
- Health momentum score = baseline health_score ± 8 (momentum) − volatility penalty, clamped 0–100 (A4).
- Churn risk score = weighted composite: health momentum 55%, usage momentum 20%, support burden 15%, referral quality 10%, clamped 0–100 (A5).
- Intervention tiers: immediate (≥75), near_term (45–74), monitor (<45) (A6).
- Action windows: immediate=3d, near_term=10d, monitor=21d (A7).
- Reason code precedence: declining_usage > high_support_load > weak_referral > low_health (A8).
- Owner queue routing by plan type and tier (A9).
- Enterprise completeness gate: missing momentum/volatility/referral forces near_term + incomplete_enterprise_profile reason (A10).
- Requirements remain the business source of intent; Architect and Auditor validate against them. Transformer is contract-only (schema.yml + approved assumptions).

## Permanent Rules Promoted to CLAUDE.md
- **Intervention Output Standards:** Intervention-facing categorical outputs must always include `accepted_values` tests and business definitions.

## Artifacts Produced
| File | Status |
|---|---|
| `dbt_project/models/intermediate/int_user_stats.sql` | Modified — added usage_hours_last_30d, usage_hours_prev_30d, usage_momentum, usage_volatility_index |
| `dbt_project/models/intermediate/int_customer_health.sql` | Modified — added health_momentum_score, churn_risk_score, intervention_tier, intervention_reason |
| `dbt_project/models/intermediate/int_retention_actions.sql` | Created — new model with action_priority, action_window_days, owner_queue, reason_code |
| `dbt_project/models/intermediate/user_summary.sql` | Modified — surfaced churn_risk_score, intervention_tier, intervention_reason, usage_momentum, action_window_days |
| `dbt_project/models/intermediate/schema.yml` | Modified — contract for all 4 sprint-touched models |
| `.ai/ACTIVE_ASSUMPTIONS.md` | Created then deleted on wrap-up — A1–A10 approved via PR #9 |

## Test Results
- **dbt run:** PASS=7, ERROR=0 (4 models + 3 hooks)
- **dbt test (sprint-touched models):** PASS=96, WARN=0, ERROR=0, TOTAL=96

## Auditor Findings
- Initial `dbt test` run failed with 36 errors: new columns and int_retention_actions table did not yet exist in DuckDB (models had not been materialized). Root cause: tests ran against stale pre-sprint tables.
- Fix: ran `dbt run` to rebuild materialized tables, then re-ran `dbt test`. All 96 tests passed on second run.
- No schema/contract mismatches detected after rebuild.
