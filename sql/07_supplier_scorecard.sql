-- =============================================================================
-- Module 7: Supplier Scorecard — Weighted Composite Score
-- =============================================================================
-- Combines 5 performance dimensions into a single 0-100 score:
--   30% On-time delivery rate
--   25% Quality (review score)
--   20% Cost efficiency (inverse of freight %)
--   15% Volume reliability (log-scaled order count)
--   10% Lead time consistency (inverse of CV)
--
-- Min-max normalization applied to each dimension.
-- Final tier classification: A (Preferred) / B (Approved) / C (Conditional) / D (Under Review)
-- =============================================================================

-- Part A: Tier distribution summary
WITH scored_suppliers AS (
  SELECT
    seller_id,
    seller_state,
    primary_category,
    total_orders,
    total_revenue,
    on_time_rate_pct,
    avg_review_score,
    freight_pct_of_revenue,
    stddev_delivery_days,
    avg_delivery_days,
    
    -- Normalize each metric to 0-100 scale
    ROUND(SAFE_DIVIDE(
      on_time_rate_pct - MIN(on_time_rate_pct) OVER(),
      MAX(on_time_rate_pct) OVER() - MIN(on_time_rate_pct) OVER()
    ) * 100, 1) AS on_time_score,
    
    ROUND(SAFE_DIVIDE(
      avg_review_score - MIN(avg_review_score) OVER(),
      MAX(avg_review_score) OVER() - MIN(avg_review_score) OVER()
    ) * 100, 1) AS quality_score,
    
    ROUND((1 - SAFE_DIVIDE(
      freight_pct_of_revenue - MIN(freight_pct_of_revenue) OVER(),
      MAX(freight_pct_of_revenue) OVER() - MIN(freight_pct_of_revenue) OVER()
    )) * 100, 1) AS cost_score,
    
    ROUND(SAFE_DIVIDE(
      LOG(total_orders) - MIN(LOG(total_orders)) OVER(),
      MAX(LOG(total_orders)) OVER() - MIN(LOG(total_orders)) OVER()
    ) * 100, 1) AS volume_score,
    
    ROUND((1 - SAFE_DIVIDE(
      SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER(),
      MAX(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER() - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER()
    )) * 100, 1) AS consistency_score

  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
    AND stddev_delivery_days IS NOT NULL
    AND avg_review_score IS NOT NULL
    AND freight_pct_of_revenue IS NOT NULL
),

final_scored AS (
  SELECT
    *,
    ROUND(
      on_time_score * 0.30 +
      quality_score * 0.25 +
      cost_score * 0.20 +
      volume_score * 0.15 +
      consistency_score * 0.10
    , 1) AS composite_score
  FROM scored_suppliers
)

SELECT
  CASE
    WHEN composite_score >= 80 THEN 'A — Preferred (80-100)'
    WHEN composite_score >= 60 THEN 'B — Approved (60-79)'
    WHEN composite_score >= 40 THEN 'C — Conditional (40-59)'
    ELSE 'D — Under Review (0-39)'
  END AS supplier_tier,
  COUNT(*) AS supplier_count,
  ROUND(AVG(composite_score), 1) AS avg_score,
  ROUND(AVG(total_orders), 0) AS avg_orders,
  ROUND(SUM(total_revenue), 0) AS tier_revenue,
  ROUND(AVG(on_time_rate_pct), 1) AS avg_on_time,
  ROUND(AVG(avg_review_score), 2) AS avg_review,
  ROUND(AVG(freight_pct_of_revenue), 1) AS avg_freight_pct
FROM final_scored
GROUP BY supplier_tier
ORDER BY supplier_tier;


-- =============================================================================
-- Part B: Top 10 best-scored suppliers
-- =============================================================================

WITH scored_suppliers AS (
  SELECT
    seller_id, seller_state, primary_category, total_orders, total_revenue,
    on_time_rate_pct, avg_review_score, freight_pct_of_revenue,
    stddev_delivery_days, avg_delivery_days,
    ROUND(SAFE_DIVIDE(on_time_rate_pct - MIN(on_time_rate_pct) OVER(), MAX(on_time_rate_pct) OVER() - MIN(on_time_rate_pct) OVER()) * 100, 1) AS on_time_score,
    ROUND(SAFE_DIVIDE(avg_review_score - MIN(avg_review_score) OVER(), MAX(avg_review_score) OVER() - MIN(avg_review_score) OVER()) * 100, 1) AS quality_score,
    ROUND((1 - SAFE_DIVIDE(freight_pct_of_revenue - MIN(freight_pct_of_revenue) OVER(), MAX(freight_pct_of_revenue) OVER() - MIN(freight_pct_of_revenue) OVER())) * 100, 1) AS cost_score,
    ROUND(SAFE_DIVIDE(LOG(total_orders) - MIN(LOG(total_orders)) OVER(), MAX(LOG(total_orders)) OVER() - MIN(LOG(total_orders)) OVER()) * 100, 1) AS volume_score,
    ROUND((1 - SAFE_DIVIDE(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER(), MAX(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER() - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER())) * 100, 1) AS consistency_score
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10 AND stddev_delivery_days IS NOT NULL AND avg_review_score IS NOT NULL AND freight_pct_of_revenue IS NOT NULL
)

SELECT
  seller_id, seller_state, primary_category, total_orders,
  ROUND(total_revenue, 0) AS revenue,
  ROUND(on_time_rate_pct, 1) AS on_time_pct,
  ROUND(avg_review_score, 2) AS review,
  ROUND(on_time_score * 0.30 + quality_score * 0.25 + cost_score * 0.20 + volume_score * 0.15 + consistency_score * 0.10, 1) AS composite_score
FROM scored_suppliers
ORDER BY composite_score DESC
LIMIT 10;


-- =============================================================================
-- Part C: Bottom 10 worst-scored suppliers
-- =============================================================================

WITH scored_suppliers AS (
  SELECT
    seller_id, seller_state, primary_category, total_orders, total_revenue,
    on_time_rate_pct, avg_review_score, freight_pct_of_revenue,
    stddev_delivery_days, avg_delivery_days,
    ROUND(SAFE_DIVIDE(on_time_rate_pct - MIN(on_time_rate_pct) OVER(), MAX(on_time_rate_pct) OVER() - MIN(on_time_rate_pct) OVER()) * 100, 1) AS on_time_score,
    ROUND(SAFE_DIVIDE(avg_review_score - MIN(avg_review_score) OVER(), MAX(avg_review_score) OVER() - MIN(avg_review_score) OVER()) * 100, 1) AS quality_score,
    ROUND((1 - SAFE_DIVIDE(freight_pct_of_revenue - MIN(freight_pct_of_revenue) OVER(), MAX(freight_pct_of_revenue) OVER() - MIN(freight_pct_of_revenue) OVER())) * 100, 1) AS cost_score,
    ROUND(SAFE_DIVIDE(LOG(total_orders) - MIN(LOG(total_orders)) OVER(), MAX(LOG(total_orders)) OVER() - MIN(LOG(total_orders)) OVER()) * 100, 1) AS volume_score,
    ROUND((1 - SAFE_DIVIDE(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days) - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER(), MAX(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER() - MIN(SAFE_DIVIDE(stddev_delivery_days, avg_delivery_days)) OVER())) * 100, 1) AS consistency_score
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10 AND stddev_delivery_days IS NOT NULL AND avg_review_score IS NOT NULL AND freight_pct_of_revenue IS NOT NULL
)

SELECT
  seller_id, seller_state, primary_category, total_orders,
  ROUND(total_revenue, 0) AS revenue,
  ROUND(on_time_rate_pct, 1) AS on_time_pct,
  ROUND(avg_review_score, 2) AS review,
  ROUND(on_time_score * 0.30 + quality_score * 0.25 + cost_score * 0.20 + volume_score * 0.15 + consistency_score * 0.10, 1) AS composite_score
FROM scored_suppliers
ORDER BY composite_score ASC
LIMIT 10;
