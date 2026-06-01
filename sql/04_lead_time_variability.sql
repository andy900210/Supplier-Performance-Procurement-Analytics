-- =============================================================================
-- Module 4: Lead Time Variability & Risk Analysis
-- =============================================================================
-- Analyzes delivery time consistency using Coefficient of Variation (CV).
-- CV = stddev / mean — higher CV = more unpredictable delivery times.
--
-- Risk tiers:
--   Low Risk:      CV ≤ 30%  → Predictable, easy to plan around
--   Medium Risk:   30% < CV ≤ 50% → Some variability, manageable
--   High Risk:     50% < CV ≤ 70% → Unpredictable, buffer stock needed
--   Critical Risk: CV > 70% → Unreliable, cannot promise delivery dates
-- =============================================================================

-- Part A: Risk tier summary
WITH seller_lead_times AS (
  SELECT
    seller_id,
    primary_category,
    seller_state,
    total_orders,
    avg_delivery_days,
    stddev_delivery_days,
    ROUND(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) * 100, 1) AS cv_pct,
    on_time_rate_pct,
    avg_review_score,
    total_revenue
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
    AND stddev_delivery_days IS NOT NULL
),

risk_classified AS (
  SELECT
    *,
    CASE
      WHEN cv_pct <= 30 THEN 'Low Risk (CV≤30%)'
      WHEN cv_pct <= 50 THEN 'Medium Risk (30%<CV≤50%)'
      WHEN cv_pct <= 70 THEN 'High Risk (50%<CV≤70%)'
      ELSE 'Critical Risk (CV>70%)'
    END AS lead_time_risk_tier
  FROM seller_lead_times
)

SELECT
  lead_time_risk_tier,
  COUNT(*) AS supplier_count,
  ROUND(AVG(avg_delivery_days), 1) AS avg_delivery,
  ROUND(AVG(stddev_delivery_days), 1) AS avg_stddev,
  ROUND(AVG(cv_pct), 1) AS avg_cv_pct,
  ROUND(AVG(on_time_rate_pct), 1) AS avg_on_time_pct,
  ROUND(AVG(avg_review_score), 2) AS avg_review,
  ROUND(SUM(total_revenue), 0) AS total_revenue_at_risk,
  ROUND(AVG(total_orders), 1) AS avg_orders
FROM risk_classified
GROUP BY lead_time_risk_tier
ORDER BY
  CASE lead_time_risk_tier
    WHEN 'Low Risk (CV≤30%)' THEN 1
    WHEN 'Medium Risk (30%<CV≤50%)' THEN 2
    WHEN 'High Risk (50%<CV≤70%)' THEN 3
    WHEN 'Critical Risk (CV>70%)' THEN 4
  END;


-- =============================================================================
-- Part B: Top 10 most unpredictable high-revenue suppliers
-- =============================================================================

SELECT
  seller_id,
  primary_category,
  seller_state,
  total_orders,
  ROUND(avg_delivery_days, 1) AS avg_delivery,
  ROUND(stddev_delivery_days, 1) AS stddev_days,
  ROUND(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) * 100, 1) AS cv_pct,
  ROUND(on_time_rate_pct, 1) AS on_time_pct,
  ROUND(total_revenue, 0) AS revenue
FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
WHERE total_orders >= 20
  AND stddev_delivery_days IS NOT NULL
ORDER BY SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) DESC
LIMIT 10;
