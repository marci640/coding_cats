## Sprint Requirements
<!-- Sprint version: 1.8.0 | Started: 2026-03-19 -->
<!-- Sprint ID: coding_cats_sprint_08 -->

### Business Rules
- **Filter:** Continue excluding users where `signup_date < '2025-01-01'`
- **Constraint:** Only `premium` and `enterprise` plan users should be flagged as high-value

### Transformation Logic
- **Modify model:** `int_plans`
- **Add column:** `is_high_value` — boolean flag, `TRUE` when `plan_type IN ('premium', 'enterprise')`, otherwise `FALSE`
- **Add column:** `days_since_signup` — integer, calculated as `CURRENT_DATE - signup_date`

### New Models / Sources
None — this sprint modifies an existing intermediate model only.

### Technical Dependencies
None — no new packages required.

### Approved Assumptions
None

### Permanent Rules (will be promoted to CLAUDE.md on sprint close)
None