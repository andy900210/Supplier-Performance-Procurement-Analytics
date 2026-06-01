-- =============================================================================
-- Module 6: Cost Optimization — Freight Benchmarking
-- =============================================================================
-- Identifies overpriced logistics corridors by state and category.
-- Benchmark: 20% freight-to-revenue ratio as target efficiency.
-- Calculates potential savings if all categories achieve benchmark.
-- =============================================================================

-- Part A: State-level logistics cost efficiency
WITH state_benchmarks AS (
  SELECT
    seller_state,
    COUNT(*) AS seller_count,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_revenue), 0) AS total_revenue,
    ROUND(SUM(total_freight_cost), 0) AS total_freight,
    ROUND(AVG(freight_pct_of_revenue), 1) AS avg_freight_pct,
    ROUND(AVG(avg_freight_per_order), 2) AS avg_freight_per_order,
    ROUND(AVG(avg_delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(on_time_rate_pct), 1) AS avg_on_time_pct
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
  GROUP BY seller_state
  HAVING seller_count >= 5
)

SELECT
  *,
  ROUND(SAFE_DIVIDE(avg_freight_per_order, avg_delivery_days), 2) AS cost_per_delivery_day,
  CASE
    WHEN avg_freight_pct <= 20 AND avg_on_time_pct >= 93 THEN 'Efficient'
    WHEN avg_freight_pct <= 25 AND avg_on_time_pct >= 90 THEN 'Acceptable'
    WHEN avg_freight_pct > 25 OR avg_on_time_pct < 90 THEN 'Inefficient'
    ELSE 'Acceptable'
  END AS logistics_efficiency
FROM state_benchmarks
ORDER BY avg_freight_pct DESC;


-- =============================================================================
-- Part B: Category-level cost analysis
-- =============================================================================

WITH category_cost AS (
  SELECT
    primary_category,
    COUNT(*) AS seller_count,
    ROUND(SUM(total_revenue), 0) AS category_revenue,
    ROUND(SUM(total_freight_cost), 0) AS category_freight,
    ROUND(AVG(freight_pct_of_revenue), 1) AS avg_freight_pct,
    ROUND(AVG(avg_freight_per_order), 2) AS avg_freight_per_order,
    ROUND(AVG(avg_delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
    AND primary_category IS NOT NULL
  GROUP BY primary_category
  HAVING seller_count >= 3
)

SELECT
  *,
  CASE 
    WHEN avg_freight_pct > 20 
    THEN ROUND(category_revenue * (avg_freight_pct - 20) / 100, 0)
    ELSE 0
  END AS potential_freight_savings,
  CASE
    WHEN avg_freight_pct > 35 THEN 'Critical — logistics eating margin'
    WHEN avg_freight_pct > 25 THEN 'Overpriced — negotiate or switch carriers'
    WHEN avg_freight_pct > 20 THEN 'Acceptable'
    ELSE 'Efficient'
  END AS cost_verdict
FROM category_cost
ORDER BY avg_freight_pct DESC
LIMIT 15;
