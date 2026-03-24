# Sprint 10: Active Assumptions (Pending TPM Review)

## Intentional Ambiguities Requiring Approval

**A1: Volatility Penalty Severity**
- Requirement: "A volatility penalty should be applied when month-to-month usage behavior is unstable; exact severity is intentionally left for approved assumptions."
- Question: What magnitude penalty (0-100 scale) should be applied when volatility_index exceeds threshold?
- Example: If volatility_index is 0.5 (high variance), should health_score drop by 5 points? 10? 20?

**A2: Usage Momentum Thresholds**
- Requirement: "Customers with declining engagement momentum should be prioritized..."
- Question: What % month-to-month change defines rising/stable/declining?
- Example: Is ±5% considered stable? Is >+5% rising? Is <-5% declining?

**A3: Usage Volatility Index Calculation**
- Requirement: "usage_volatility_index capturing variation across recent periods (bounded numeric)"
- Question: Should this be coefficient of variation (std_dev / mean)? Range: 0-1 or 0-100?
- Question: How many recent periods to calculate variance (last 3 months? 6 months? 12?

**A4: Health Momentum Score Formula**
- Requirement: "Add health_momentum_score to reflect trend impact on current health"
- Question: Should momentum directly adjust current health (e.g., health_score + momentum_adjustment)?
- Question: Or is it a separate score combined later in churn_risk_score?

**A5: Churn Risk Score Composition**
- Requirement: "churn_risk_score on a 0-100 scale using health_score, usage_momentum, support_burden_flag, and referral quality"
- Question: What are the relative weights? (e.g., health 40%, momentum 30%, burden 20%, referral 10%?)
- Question: How does referral quality scale to 0-100?

**A6: Intervention Tier Thresholds**
- Requirement: "intervention_tier (e.g., immediate, near_term, monitor) based on churn_risk_score..."
- Question: What score ranges define immediate/near_term/monitor? (e.g., <30=monitor, 30-70=near_term, >70=immediate?)
- Question: Are enterprise customers exempt from immediate tier per "stricter completeness expectations"?

**A7: Action Window Days Logic**
- Requirement: "Derive action_window_days so higher-risk customers are contacted sooner"
- Question: Is this a linear inverse mapping (risk 100 → 1 day, risk 0 → 30 days)?
- Question: Or are there discrete buckets tied to intervention_tier?

**A8: Intervention Reason Dominant Driver**
- Requirement: "intervention_reason text/code describing the dominant driver of the assigned tier"
- Question: What is the precedence order for selecting dominant driver (health < momentum < burden < referral)?
- Question: What are the exact reason code values (e.g., 'low_health', 'declining_usage', 'high_support', 'weak_referral')?

**A9: Owner Queue Assignment**
- Requirement: "owner_queue field in int_retention_actions"
- Question: How are queues determined? (CSM vs support vs product vs expansion?)
- Question: Does queue depend on plan_type, risk_band, or both?

**A10: Enterprise Completeness Standard**
- Requirement: "Enterprise customers should continue to meet stricter completeness expectations..."
- Question: What fields/conditions must be non-null or validated for enterprise to be eligible for action?
- Question: Does this block intervention_tier assignment or just filter output rows?

---

## Approved Assumptions
(To be populated after TPM review and label approval)

---

## Next Step
**Awaiting TPM approval.** Transformer is BLOCKED until these are resolved.
Once `approved-by-tpm` label is applied to PR, approved assumptions will be pulled into this section.
