-- =============================================================================
-- Module 2: Supplier Reliability Matrix
-- =============================================================================
-- Classifies suppliers into 4 quadrants based on:
--   X-axis: Reliability (on-time delivery rate)
--   Y-axis: Quality (average review score)
--
-- Quadrants:
--   Star     = High quality + High reliability → Increase volume
--   Reliable = Low quality + High reliability  → Coaching needed
--   Risky    = High quality + Low reliability  → Fix logistics
--   Exit     = Low quality + Low reliability   → Phase out
--
-- Thresholds: Median-based (data-driven, not arbitrary)
-- =============================================================================

WITH thresholds AS (
  SELECT
    APPROX_QUANTILES(on_time_rate_pct, 100)[OFFSET(50)] AS median_on_time,
    APPROX_QUANTILES(avg_review_score, 100)[OFFSET(50)] AS median_review
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
),

classified AS (
  SELECT
    sm.*,
    t.median_on_time,
    t.median_review,
    CASE
      WHEN sm.on_time_rate_pct >= t.median_on_time AND sm.avg_review_score >= t.median_review THEN 'Star'
      WHEN sm.on_time_rate_pct >= t.median_on_time AND sm.avg_review_score < t.median_review THEN 'Reliable'
      WHEN sm.on_time_rate_pct < t.median_on_time AND sm.avg_review_score >= t.median_review THEN 'Risky'
      ELSE 'Exit'
    END AS quadrant
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master` sm
  CROSS JOIN thresholds t
  WHERE sm.total_orders >= 10
)

-- Quadrant summary
SELECT
  quadrant,
  COUNT(*) AS supplier_count,
  ROUND(AVG(total_orders), 1) AS avg_orders,
  ROUND(AVG(total_revenue), 0) AS avg_revenue,
  ROUND(AVG(on_time_rate_pct), 1) AS avg_on_time_pct,
  ROUND(AVG(avg_review_score), 2) AS avg_review,
  ROUND(SUM(total_revenue), 0) AS total_quadrant_revenue,
  ROUND(AVG(freight_pct_of_revenue), 1) AS avg_freight_pct
FROM classified
GROUP BY quadrant
ORDER BY 
  CASE quadrant 
    WHEN 'Star' THEN 1 
    WHEN 'Reliable' THEN 2 
    WHEN 'Risky' THEN 3 
    WHEN 'Exit' THEN 4 
  END;
