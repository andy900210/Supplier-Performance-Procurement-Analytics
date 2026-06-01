-- =============================================================================
-- Module 5: Supplier Concentration & Dependency Risk
-- =============================================================================
-- Uses Herfindahl-Hirschman Index (HHI) to measure market concentration.
-- HHI = sum of squared market shares (scale 0-10,000):
--   < 1,500  = Competitive (low risk)
--   1,500-2,500 = Moderately concentrated
--   > 2,500  = Highly concentrated (high risk)
--
-- Identifies single-source dependencies at category level.
-- =============================================================================

-- Part A: Overall marketplace concentration
WITH seller_shares AS (
  SELECT
    seller_id,
    primary_category,
    total_revenue,
    total_orders,
    ROUND(SAFE_DIVIDE(total_revenue, SUM(total_revenue) OVER()) * 100, 4) AS revenue_share_pct
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
),

overall_hhi AS (
  SELECT
    ROUND(SUM(POWER(revenue_share_pct, 2)), 2) AS marketplace_hhi,
    COUNT(*) AS qualified_sellers,
    ROUND(SUM(CASE WHEN revenue_share_pct >= 1.0 THEN revenue_share_pct ELSE 0 END), 1) AS top_seller_combined_share
  FROM seller_shares
)

SELECT * FROM overall_hhi;


-- =============================================================================
-- Part B: Category-level concentration (single-source risk identification)
-- =============================================================================

WITH category_seller_revenue AS (
  SELECT
    primary_category,
    seller_id,
    total_revenue,
    total_orders,
    ROUND(SAFE_DIVIDE(total_revenue, SUM(total_revenue) OVER(PARTITION BY primary_category)) * 100, 1) AS category_share_pct,
    ROW_NUMBER() OVER(PARTITION BY primary_category ORDER BY total_revenue DESC) AS rank_in_category
  FROM `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master`
  WHERE total_orders >= 10
    AND primary_category IS NOT NULL
),

category_concentration AS (
  SELECT
    primary_category,
    COUNT(*) AS supplier_count,
    ROUND(SUM(total_revenue), 0) AS category_revenue,
    ROUND(SUM(POWER(category_share_pct, 2)), 1) AS category_hhi,
    MAX(CASE WHEN rank_in_category = 1 THEN category_share_pct END) AS top1_share_pct,
    MAX(CASE WHEN rank_in_category = 1 THEN seller_id END) AS top1_seller_id,
    SUM(CASE WHEN rank_in_category <= 3 THEN category_share_pct ELSE 0 END) AS top3_combined_share
  FROM category_seller_revenue
  GROUP BY primary_category
  HAVING supplier_count >= 3
)

SELECT
  primary_category,
  supplier_count,
  category_revenue,
  category_hhi,
  ROUND(top1_share_pct, 1) AS top1_share_pct,
  ROUND(top3_combined_share, 1) AS top3_combined_share,
  CASE
    WHEN category_hhi > 2500 THEN 'Highly Concentrated'
    WHEN category_hhi > 1500 THEN 'Moderately Concentrated'
    ELSE 'Competitive'
  END AS concentration_risk,
  ROUND(category_revenue * top1_share_pct / 100, 0) AS revenue_at_risk_if_top1_fails
FROM category_concentration
ORDER BY category_hhi DESC
LIMIT 15;
