# Sprint 09 Active Assumptions

The Architect identified material ambiguity in Sprint 09 requirements. The following assumptions were required to produce a technical contract.

- **A1 — `plan_value_band` thresholds:** classify `amount < 30` as `entry`, `amount >= 30 AND amount < 100` as `growth`, `amount >= 100 AND amount <= 200` as `premium`, and `amount > 200` as `strategic`.
- **A2 — `plan_rank` mapping:** assign `basic = 1`, `premium = 2`, and `enterprise = 3` for downstream ordering and scoring.
- **A3 — `engagement_score` shape:** compute a bounded numeric score on a `0` to `100` scale using `total_usage_hours` and `total_phone_calls`, with usage contributing more heavily than support interactions.
- **A4 — `support_burden_flag` threshold:** mark `TRUE` when `total_phone_calls >= 2`; otherwise `FALSE`.
- **A5 — `usage_recency_hint` buckets:** derive recency from the most recent observed activity date available from `stg_phone_log.call_timestamp` and `stg_usage_hours` month/year using `current`, `recent`, `stale`, and `none` buckets.
- **A6 — referral quality input:** use `stg_referral_codes.status` as the sole referral-quality input and treat missing referral records as neutral.
- **A7 — referral quality scoring:** map referral status to score contribution as `active = 20`, `inactive = 0`, `expired = -10`, `missing = 0`.
- **A8 — valuable-plan exemption:** interpret “sufficiently valuable plans” as `plan_value_band = 'strategic'`, meaning those customers are exempt from the support-burden penalty.
- **A9 — `health_score` composition:** compute `health_score` on a `0` to `100` scale using weighted plan value, engagement, support burden, and referral quality, with support burden acting as a negative adjustment.
- **A10 — `risk_band` thresholds:** use exactly three levels for Sprint 09: `low` for `health_score >= 70`, `medium` for `health_score >= 40 AND < 70`, and `high` for `health_score < 40`.
- **A11 — `retention_priority` mapping:** use `p1` for `risk_band = 'high'`, `p2` for `risk_band = 'medium'`, and `p3` for `risk_band = 'low'`.
