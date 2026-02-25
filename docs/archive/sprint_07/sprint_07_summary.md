# Sprint 07 Archive — Add price_group Classification
**Closed:** 2026-02-25
**Version:** 1.7.0
**Branch:** `sprint_07`

## Business Rules Applied
- Added `price_group` column to `int_plans` intermediate model.
- `price_group = 'less than 30'` when `amount < 30`.
- `price_group = 'greater than 200'` when `amount > 200`.
- `price_group = 'standard'` for all other amounts (`>= 30 AND <= 200`) — resolved via Assumption A1.
- Boundary operators are strict inequalities (`<` and `>`) — resolved via Assumption A2.
- `price_group` can never be blank or null (enforced by CASE with ELSE + `not_null` test).

## Permanent Rules Promoted to CLAUDE.md
None

## Artifacts Produced
| File | Action |
|------|--------|
| `dbt_project/models/intermediate/int_plans.sql` | Modified — added `price_group` CASE column |
| `dbt_project/models/intermediate/schema.yml` | Modified — added `price_group` column spec with tests |
| `.ai/ACTIVE_ASSUMPTIONS.md` | Created — 2 assumptions (A1: default group, A2: boundary operators) |

## Test Results
- **14 tests passed, 0 failures** on `int_plans` model
- Key tests: `not_null_int_plans_price_group`, `accepted_values_int_plans_price_group` (`less than 30`, `standard`, `greater than 200`)

## Auditor Findings
No findings — AUDIT PASS (2026-02-24, 0 discrepancies).
