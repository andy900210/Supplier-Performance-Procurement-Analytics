-- =============================================================================
-- Module 1: Supplier Master View
-- =============================================================================
-- Creates a comprehensive supplier-level view aggregating 20+ KPIs across
-- volume, revenue, delivery, quality, and cost dimensions.
-- 
-- Foundation for all subsequent analysis modules.
-- =============================================================================

CREATE OR REPLACE VIEW `stalwart-coast-484305-c5.supplier_procurement_analytics.supplier_master` AS
WITH seller_delivery AS (
  -- Deduplicate to one row per seller-order for delivery metrics
  SELECT
    oi.seller_id,
    o.order_id,
    MIN(oi.price) AS min_item_price,
    SUM(oi.price) AS order_revenue,
    SUM(oi.freight_value) AS order_freight,
    COUNT(DISTINCT oi.product_id) AS products_in_order,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CASE 
      WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 
      ELSE 0 
    END AS is_on_time
  FROM `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_order_items_dataset` oi
  JOIN `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_orders_dataset` o
    ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.seller_id, o.order_id, o.order_purchase_timestamp, 
           o.order_delivered_customer_date, o.order_estimated_delivery_date
),

seller_review_agg AS (
  -- Aggregate reviews per seller (not per order-item to avoid duplication)
  SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNTIF(r.review_score <= 2) AS low_review_count,
    COUNT(r.review_score) AS total_reviews,
    ROUND(SAFE_DIVIDE(COUNTIF(r.review_score <= 2), COUNT(r.review_score)) * 100, 2) AS low_review_pct
  FROM `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_order_items_dataset` oi
  JOIN `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_order_reviews_dataset` r
    ON oi.order_id = r.order_id
  GROUP BY oi.seller_id
),

seller_products AS (
  SELECT
    oi.seller_id,
    p.product_category_name,
    t.string_field_1 AS product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS category_orders
  FROM `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_order_items_dataset` oi
  JOIN `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_products_dataset` p
    ON oi.product_id = p.product_id
  LEFT JOIN `stalwart-coast-484305-c5.ecommerce_supply_chain.product_category_name_translation` t
    ON p.product_category_name = t.string_field_0
  GROUP BY oi.seller_id, p.product_category_name, t.string_field_1
),

seller_primary_category AS (
  SELECT
    seller_id,
    product_category_name_english AS primary_category
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY category_orders DESC) AS rn
    FROM seller_products
  )
  WHERE rn = 1
)

SELECT
  s.seller_id,
  s.seller_city,
  s.seller_state,
  spc.primary_category,

  -- Volume metrics
  COUNT(sd.order_id) AS total_orders,
  SUM(sd.products_in_order) AS total_items_sold,

  -- Revenue metrics
  ROUND(SUM(sd.order_revenue), 2) AS total_revenue,
  ROUND(AVG(sd.order_revenue), 2) AS avg_order_value,
  ROUND(SUM(sd.order_freight), 2) AS total_freight_cost,
  ROUND(AVG(sd.order_freight), 2) AS avg_freight_per_order,
  ROUND(SAFE_DIVIDE(SUM(sd.order_freight), SUM(sd.order_revenue)) * 100, 2) AS freight_pct_of_revenue,

  -- Delivery metrics
  ROUND(AVG(DATE_DIFF(sd.order_delivered_customer_date, sd.order_purchase_timestamp, DAY)), 1) AS avg_delivery_days,
  ROUND(STDDEV(DATE_DIFF(sd.order_delivered_customer_date, sd.order_purchase_timestamp, DAY)), 2) AS stddev_delivery_days,
  ROUND(AVG(DATE_DIFF(sd.order_estimated_delivery_date, sd.order_delivered_customer_date, DAY)), 1) AS avg_buffer_days,

  -- On-time performance (one count per order, not per item)
  SUM(sd.is_on_time) AS on_time_count,
  ROUND(SAFE_DIVIDE(SUM(sd.is_on_time), COUNT(sd.order_id)) * 100, 2) AS on_time_rate_pct,

  -- Quality metrics
  sr.avg_review_score,
  sr.low_review_count,
  sr.low_review_pct,

  -- Activity period
  MIN(sd.order_purchase_timestamp) AS first_order_date,
  MAX(sd.order_purchase_timestamp) AS last_order_date,
  DATE_DIFF(MAX(sd.order_purchase_timestamp), MIN(sd.order_purchase_timestamp), DAY) AS active_days

FROM `stalwart-coast-484305-c5.ecommerce_supply_chain.olist_sellers_dataset` s
JOIN seller_delivery sd ON s.seller_id = sd.seller_id
LEFT JOIN seller_review_agg sr ON s.seller_id = sr.seller_id
LEFT JOIN seller_primary_category spc ON s.seller_id = spc.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state, spc.primary_category,
         sr.avg_review_score, sr.low_review_count, sr.low_review_pct
HAVING total_orders >= 1;
