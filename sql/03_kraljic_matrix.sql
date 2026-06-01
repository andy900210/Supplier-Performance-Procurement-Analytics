-- =============================================================================
-- Module 3: Kraljic Portfolio Matrix
-- =============================================================================
-- Classifies product categories into 4 procurement strategy segments:
--   Strategic:    High profit impact + High supply risk → Need partnerships
--   Leverage:     High profit impact + Low supply risk  → Negotiate hard
--   Bottleneck:   Low profit impact + High supply risk  → Secure alternatives
--   Non-critical: Low profit impact + Low supply risk   → Automate/simplify
--
-- Profit impact: Revenue rank (percentile)
-- Supply risk: Composite of supplier scarcity + delivery variability + reliability
-- =============================================================================

WITH category_metrics AS (
  SELECT
    sm.primary_category,
    COUNT(*) AS supplier_count,
    SUM(sm.total_revenue) AS category_revenue,
    SUM(sm.total_orders) AS category_orders,
    ROUND(AVG(sm.on_time_rate_pct), 1) AS avg_on_time_pct,
    ROUND(AVG(sm.avg_review_score), 2) AS avg_review,
    ROUND(STDDEV(sm.avg_delivery_days), 2) AS delivery_variability,
    ROUND(AVG(sm.freight_pct_of_revenue), 1) AS avg_freight_pct
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master` sm
  WHERE sm.total_orders >= 10
    AND sm.primary_category IS NOT NULL
  GROUP BY sm.primary_category
  HAVING supplier_count >= 3
),

scored AS (
  SELECT
    *,
    -- Profit impact: percentile rank by revenue
    PERCENT_RANK() OVER (ORDER BY category_revenue) AS profit_impact_rank,
    -- Supply risk components
    PERCENT_RANK() OVER (ORDER BY supplier_count DESC) AS supply_scarcity_rank,
    PERCENT_RANK() OVER (ORDER BY delivery_variability) AS variability_rank,
    PERCENT_RANK() OVER (ORDER BY avg_on_time_pct DESC) AS reliability_rank
  FROM category_metrics
),

classified AS (
  SELECT
    *,
    profit_impact_rank AS profit_impact_score,
    ROUND((supply_scarcity_rank + variability_rank + reliability_rank) / 3, 3) AS supply_risk_score,
    CASE
      WHEN profit_impact_rank >= 0.5 AND (supply_scarcity_rank + variability_rank + reliability_rank) / 3 >= 0.5 THEN 'Strategic'
      WHEN profit_impact_rank >= 0.5 AND (supply_scarcity_rank + variability_rank + reliability_rank) / 3 < 0.5 THEN 'Leverage'
      WHEN profit_impact_rank < 0.5 AND (supply_scarcity_rank + variability_rank + reliability_rank) / 3 >= 0.5 THEN 'Bottleneck'
      ELSE 'Non-critical'
    END AS kraljic_quadrant
  FROM scored
)

SELECT
  kraljic_quadrant,
  COUNT(*) AS category_count,
  ARRAY_AGG(primary_category ORDER BY category_revenue DESC LIMIT 5) AS top_categories,
  ROUND(SUM(category_revenue), 0) AS total_revenue,
  ROUND(AVG(supplier_count), 1) AS avg_suppliers,
  ROUND(AVG(avg_on_time_pct), 1) AS avg_on_time,
  ROUND(AVG(avg_review), 2) AS avg_review,
  ROUND(AVG(avg_freight_pct), 1) AS avg_freight_pct
FROM classified
GROUP BY kraljic_quadrant
ORDER BY
  CASE kraljic_quadrant
    WHEN 'Strategic' THEN 1
    WHEN 'Leverage' THEN 2
    WHEN 'Bottleneck' THEN 3
    WHEN 'Non-critical' THEN 4
  END;
