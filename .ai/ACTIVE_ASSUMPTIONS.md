# Sprint 10: Active Assumptions (Pending TPM Review)

## Proposed Assumptions for Approval

**A1: Volatility Penalty Severity**
- **Ambiguity/Gap:** Requirement states "A volatility penalty should be applied when month-to-month usage behavior is unstable; exact severity is intentionally left for approved assumptions." No magnitude specified. Also missing: volatility threshold (>0.3? >0.5?).
- **Decision (Proposed Default):** Apply volatility penalty of `10` points to `health_momentum_score` when `usage_volatility_index > 0.35`; otherwise `0`.
- **Rationale:** Medium penalty captures instability without overwhelming baseline health. Threshold 0.35 avoids noise while flagging real variance.
- **Implementation Impact:** `int_customer_health.health_momentum_score`; tests: non-null and bounded 0-100.
- **TPM Action:** approve / edit / reject.

**A2: Usage Momentum Thresholds**
- **Ambiguity/Gap:** Requirement says "Customers with declining engagement momentum should be prioritized..." but provides no thresholds for what constitutes rising/stable/declining. No pct_change cutoffs specified.
- **Decision (Proposed Default):** Let `pct_change = (usage_hours_last_30d - usage_hours_prev_30d) / NULLIF(usage_hours_prev_30d, 0)`.
  - `rising` if `pct_change >= 0.10`
  - `declining` if `pct_change <= -0.10`
  - `stable` otherwise
- **Rationale:** ±10% avoids overreacting to noise while flagging meaningful shifts.
- **Implementation Impact:** `int_user_stats.usage_momentum`; tests: `accepted_values` = `['rising','stable','declining']`.
- **TPM Action:** approve / edit / reject.

**A3: Usage Volatility Index Calculation**
- **Ambiguity/Gap:** Requirement says "usage_volatility_index capturing variation across recent periods (bounded numeric)" but does not specify: formula (std_dev? coefficient of variation?), bounds (0-1 or 0-100?), or lookback window (3 months? 6?)
- **Decision (Proposed Default):** `usage_volatility_index = LEAST(1.00, COALESCE(STDDEV_SAMP(monthly_usage_hours) / NULLIF(AVG(monthly_usage_hours), 0), 0))` over last 3 monthly periods.
- **Rationale:** Coefficient of variation is scale-independent and bounded to 0-1 for stable interpretation. 3-month window balances recency with statistical stability.
- **Implementation Impact:** `int_user_stats.usage_volatility_index`; tests: not-null and range `0 <= x <= 1`.
- **TPM Action:** approve / edit / reject.

**A4: Health Momentum Score Formula**
- **Ambiguity/Gap:** Requirement says "Add health_momentum_score to reflect trend impact on current health" but does not specify: formula method, weighting of momentum vs. baseline health, or penalty structure for volatility.
- **Decision (Proposed Default):** `health_momentum_score = CLAMP_0_100(health_score + momentum_adjustment - volatility_penalty)` where momentum adjustment is `+8` (rising), `0` (stable), `-8` (declining).
- **Rationale:** Symmetric momentum adjustment keeps trend influence visible but controlled. Separate volatility penalty avoids double-counting.
- **Implementation Impact:** `int_customer_health.health_momentum_score`; tests: not-null and range `0-100`.
- **TPM Action:** approve / edit / reject.

**A5: Churn Risk Score Composition**
- **Ambiguity/Gap:** Requirement specifies churn_risk_score should use health_score, usage_momentum, support_burden_flag, and referral quality on 0-100 scale, but does not define: relative weights, how to scale non-numeric fields to 0-100, or composition formula.
- **Decision (Proposed Default):** `churn_risk_score = CLAMP_0_100((100 - health_momentum_score) * 0.55 + momentum_risk * 0.20 + support_risk * 0.15 + referral_risk * 0.10)`.
  - `momentum_risk`: rising=20, stable=50, declining=80
  - `support_risk`: TRUE=80, FALSE=20
  - `referral_risk`: map `referral_quality_score` from 0-100 to inverse risk (`100 - referral_quality_score`)
- **Rationale:** Baseline health remains primary (55%), with momentum/support/referral as secondary drivers (45% total). Inverse logic for referral: higher quality = lower risk.
- **Implementation Impact:** `int_customer_health.churn_risk_score`; tests: not-null and range `0-100`.
- **TPM Action:** approve / edit / reject.

**A6: Intervention Tier Thresholds**
- **Ambiguity/Gap:** Requirement mentions intervention_tier with examples (immediate, near_term, monitor) but does not specify: score ranges for each tier, or whether enterprise customers have different thresholds per "stricter completeness expectations".
- **Decision (Proposed Default):**
  - `immediate` if `churn_risk_score >= 75`
  - `near_term` if `45 <= churn_risk_score < 75`
  - `monitor` if `< 45`
- **Rationale:** Three clear operational bands with escalation at high risk. No enterprise exception at tier level (A10 handles enterprise completeness separately).
- **Implementation Impact:** `int_customer_health.intervention_tier`; tests: `accepted_values` = `['immediate','near_term','monitor']`.
- **TPM Action:** approve / edit / reject.

**A7: Action Window Days Logic**
- **Ambiguity/Gap:** Requirement says "Derive action_window_days so higher-risk customers are contacted sooner" but does not specify: continuous formula vs. discrete buckets, or exact day ranges.
- **Decision (Proposed Default):** Map from intervention tier:
  - `immediate` => `3` days
  - `near_term` => `10` days
  - `monitor` => `21` days
- **Rationale:** Discrete windows are easier for weekly ops scheduling than continuous formulas and align with operational cadences.
- **Implementation Impact:** `int_retention_actions.action_window_days`, `user_summary.action_window_days`; tests: not-null and positive integer.
- **TPM Action:** approve / edit / reject.

**A8: Intervention Reason / Reason Code Precedence**
- **Ambiguity/Gap:** Requirement calls for intervention_reason describing "dominant driver" but does not specify: selection logic, precedence order, or exact reason code values.
- **Decision (Proposed Default):** Dominant driver precedence:
  1. `declining_usage` (if momentum is declining)
  2. `high_support_load` (if support_burden_flag = TRUE)
  3. `weak_referral` (if referral_quality_score < 40)
  4. `low_health` (fallback)
- **Rationale:** Prioritizes actionable and behavior-based signals over aggregate fallback. Operations can act directly on usage/support/referral signals.
- **Implementation Impact:** `int_customer_health.intervention_reason`, `int_retention_actions.reason_code`; tests: not-null and accepted values on reason code.
- **TPM Action:** approve / edit / reject.

**A9: Owner Queue Assignment**
- **Ambiguity/Gap:** Requirement mentions `owner_queue` field but does not specify: queue names, how queues are determined, or assignment logic (plan-based vs. risk-based vs. both).
- **Decision (Proposed Default):**
  - `enterprise` + (`immediate` or `near_term`) => `csm_enterprise`
  - non-enterprise + `immediate` => `retention_specialist`
  - `near_term` => `csm_general`
  - `monitor` => `lifecycle_nurture`
- **Rationale:** Aligns queue ownership with account complexity and urgency. High-value accounts get specialized handling.
- **Implementation Impact:** `int_retention_actions.owner_queue`; tests: accepted values for queue list.
- **TPM Action:** approve / edit / reject.

**A10: Enterprise Completeness Standard**
- **Ambiguity/Gap:** Requirement says "Enterprise customers should continue to meet stricter completeness expectations" but does not specify: which fields must be complete, what happens if incomplete, or how strictness applies (blocking tier assignment vs. filtering output vs. applying penalties).
- **Decision (Proposed Default):** Enterprise records require non-null `usage_momentum`, `usage_volatility_index`, and `referral_quality_score`; if missing, force `intervention_tier = 'near_term'` and reason `incomplete_enterprise_profile`.
- **Rationale:** Maintains conservative handling of enterprise accounts when key risk inputs are incomplete. Prevents gaps from being misinterpreted as low risk.
- **Implementation Impact:** `int_customer_health.intervention_tier`, `int_customer_health.intervention_reason`, `int_retention_actions.reason_code`; tests include accepted values for new reason code.
- **TPM Action:** approve / edit / reject.

---

## TPM Response Block (Edit In Place)
For each item A1–A10, edit directly in the PR body:
- Replace `approve / edit / reject` with your decision.
- If **editing**: overwrite the `Decision (Proposed Default)` value with your preferred value inline — these edited values become the implementation contract.
- Example: change `rising if pct_change >= 0.10` → `rising if pct_change >= 0.05` directly in the A2 block.

> **How edits flow:** On `continue sprint`, the orchestrator syncs the PR body back to `.ai/ACTIVE_ASSUMPTIONS.md`. The Transformer then reads both `schema.yml` (structure) and `ACTIVE_ASSUMPTIONS.md` (exact values) to implement SQL. Your inline edits here are the final decision — no separate handoff needed.

---

## Next Step
**Awaiting TPM approval.** Transformer remains BLOCKED until `approved-by-tpm` label is applied and assumptions are synced from PR body.
