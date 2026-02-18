## Sprint Requirements
<!-- Sprint version: 1.3.0 | Started: 2026-02-18 -->

### Business Rules
- **Filter:** Exclude any rows from `int_plans` where `discount_amount` is 0 or NULL

### Transformation Logic
- **Add column:** `CASE WHEN amount >= 100 THEN 'high_value' ELSE 'standard' END AS customer_tier` in `int_plans`
- **Add column:** Total feature count per benefit: `(email_support::INT + live_chat::INT + phone_support::INT + api_access::INT + custom_integrations::INT + sla_guarantee::INT) AS total_features` in `stg_benefit_features`

### New Models / Sources
- **New seed:** `benefit_features.csv` → `stg_benefit_features` (PK: `benefit`)
  - Joins to `stg_plans` on `benefit`
- **New model:** `int_plan_features` — joins `stg_plans` to `stg_benefit_features` on `benefit` (PK: `plan_type`), enriches plans with feature flags and total feature count

### Permanent Rules (will be promoted to CLAUDE.md on sprint close)
<!-- Mark any rule here as "Global" if it should survive this sprint. Example: -->
<!-- - **Global:** All timestamp columns must use `CAST(CURRENT_TIMESTAMP AS TIMESTAMP)` -->
