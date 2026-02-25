## Sprint Requirements
<!-- Sprint version: 1.7.0 | Started: 2026-02-24 -->
**Sprint ID:** coding_cats_sprint_07
**Goal:** Add a `price_group` classification column to the plans model.

### Business Rules
- Add a new column `price_group` to the plans transformation.
- If the plan amount is less than 30, the value should be `'less than 30'`.
- If the plan amount is greater than 200, the value should be `'greater than 200'`.
- The `price_group` column can never be blank or null.

### Transformation Logic
- Apply the `price_group` logic to the intermediate plans model.
- Include `processed_at` timestamp as per project standards.

### New Models / Sources
- No new models. Modify existing `int_plans` model.

### Technical Dependencies
- None. Uses existing seeds and models.

### Permanent Rules (will be promoted to CLAUDE.md on sprint close)
- None