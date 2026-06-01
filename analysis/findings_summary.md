# Analysis Findings Summary

## Dataset Overview
- **Source:** Olist Brazilian E-Commerce (public dataset)
- **Platform:** Google BigQuery
- **Scope:** 99,441 orders | 112,650 order items | 2,970 active sellers | 32,951 products
- **Period:** 2016–2018

---

## Module 1: Supplier Master View

**Metrics created (per supplier):**
| Dimension | Key Fields |
|-----------|-----------|
| Volume | total_orders, total_items_sold |
| Revenue | total_revenue, avg_order_value, freight_pct_of_revenue |
| Delivery | avg_delivery_days, stddev_delivery_days, avg_buffer_days |
| On-time | on_time_count, on_time_rate_pct |
| Quality | avg_review_score, low_review_count, low_review_pct |
| Activity | first_order_date, last_order_date, active_days |

**Summary statistics:**
- 2,970 active sellers
- Avg 32.9 orders per seller
- 91.6% average on-time rate
- 4.07 average review score
- 4,452 BRL average revenue per seller

---

## Module 2: Supplier Reliability Matrix

**Methodology:** Median-split on on-time rate and review score creates 4 quadrants.

| Quadrant | Suppliers | Avg Revenue | On-Time % | Review | Total Revenue |
|----------|-----------|-------------|-----------|--------|---------------|
| Star | 389 (31%) | 7,972 | 97.5% | 4.42 | 3.1M BRL |
| Reliable | 231 (19%) | 10,185 | 97.0% | 3.84 | 2.4M BRL |
| Risky | 233 (19%) | 9,643 | 88.8% | 4.37 | 2.2M BRL |
| Exit | 385 (31%) | 11,185 | 85.7% | 3.73 | 4.3M BRL |

**Key Finding:** Exit-quadrant suppliers generate the most total revenue (4.3M BRL) with highest avg orders (92.6) — they're deeply embedded in the business despite poor performance. Star suppliers are under-utilized (61.5 avg orders). Immediate action: shift volume from Exit → Star.

---

## Module 3: Kraljic Portfolio Matrix

**Methodology:** Categories classified by profit impact (revenue percentile rank) × supply risk (composite of supplier count, delivery variability, reliability).

| Quadrant | Categories | Revenue | Avg Suppliers | Strategy |
|----------|-----------|---------|---------------|----------|
| Strategic | 6 | 1.69M | 25.7 | Build partnerships |
| Leverage | 16 | 9.31M | 57.2 | Negotiate aggressively |
| Bottleneck | 12 | 291K | 4.5 | Secure alternatives |
| Non-critical | 10 | 465K | 7.6 | Automate procurement |

**Key Finding:** Leverage categories dominate (79% of revenue) with many suppliers — strong negotiating position. Bottleneck categories have only 4.5 avg suppliers and highest freight cost (26.2%) — vulnerable to supply disruption with no easy alternatives.

---

## Module 4: Lead Time Variability & Risk

**Methodology:** Coefficient of Variation (CV = stddev/mean) measures delivery predictability.

| Risk Tier | Suppliers | Avg CV% | On-Time | Revenue at Risk |
|-----------|-----------|---------|---------|-----------------|
| Low (≤30%) | 12 (1%) | 25.2% | 95.1% | 21K |
| Medium (30-50%) | 198 (16%) | 43.1% | 94.9% | 905K |
| High (50-70%) | 526 (42%) | 60.6% | 92.4% | 5.3M |
| Critical (>70%) | 502 (41%) | 87.3% | 90.6% | 5.8M |

**Key Finding:** 83% of suppliers are in High or Critical risk tiers. $11M BRL flows through unpredictable suppliers. Average delivery days are similar across tiers (~11-12d) — the problem isn't speed, it's consistency. Geographic pattern: MG (Minas Gerais) and PR (Paraná) dominate worst offenders.

---

## Module 5: Supplier Concentration & Dependency

**Methodology:** Herfindahl-Hirschman Index (HHI) at marketplace and category level.

**Marketplace level:** HHI = 43.74 (highly competitive, no macro risk)

**Category level (top risks):**

| Category | Suppliers | Top-1 Share | HHI | Revenue at Risk |
|----------|-----------|-------------|-----|-----------------|
| home_appliances | 5 | 84.8% | 7,270 | 39,937 |
| home_appliances_2 | 4 | 82.0% | 6,842 | 51,050 |
| office_furniture | 8 | 70.0% | 5,175 | 186,549 |
| small_appliances | 3 | 62.9% | 5,192 | 44,187 |

**Key Finding:** All 15 analyzed categories are "Highly Concentrated" (HHI > 2,500). 9 of 15 have top-3 suppliers controlling 100%. Office furniture has largest financial exposure: 186K BRL depends on a single seller. The marketplace appears diversified at macro level but has severe single-source dependencies at category level.

---

## Module 6: Cost Optimization

**Methodology:** Freight-to-revenue ratio benchmarking. Target: 20% as efficient threshold.

**State-level:**
| State | Sellers | Freight % | On-Time | Verdict |
|-------|---------|-----------|---------|---------|
| GO | 15 | 26.4% | 97.1% | Inefficient (overpaying for premium) |
| SP | 763 | 24.1% | 91.2% | Acceptable (hub, volume congestion) |
| BA | 8 | 15.1% | 93.7% | Efficient |

**Category-level (worst offenders):**
| Category | Freight % | Savings Potential | Verdict |
|----------|-----------|-------------------|---------|
| christmas_supplies | 46.3% | 1,279 | Critical |
| electronics | 42.4% | 21,731 | Critical |
| furniture_decor | 29.5% | 79,894 | Overpriced |
| telephony | 29.3% | 41,711 | Overpriced |

**Key Finding:** Total identified freight savings: ~215K BRL across all overpriced categories. Furniture/decor has largest absolute opportunity (79.9K BRL). Electronics is most inefficient ratio-wise (42.4% — shipping costs nearly match product value).

---

## Module 7: Supplier Scorecard

**Methodology:** Min-max normalized composite score. Weights: 30% on-time + 25% quality + 20% cost efficiency + 15% volume + 10% consistency.

| Tier | Suppliers | Avg Score | Revenue | On-Time | Review | Freight % |
|------|-----------|-----------|---------|---------|--------|-----------|
| A — Preferred | 60 (5%) | 81.4 | 2.6M | 96.9% | 4.46 | 13.5% |
| B — Approved | 1,083 (87%) | 71.5 | 9.1M | 92.9% | 4.13 | 23.0% |
| C — Conditional | 93 (8%) | 54.7 | 243K | 80.2% | 3.42 | 38.1% |
| D — Under Review | 2 (<1%) | 31.9 | 22K | 56.1% | 2.21 | 47.1% |

**Key Finding:** Only 5% earn "Preferred" status — they also have the lowest freight costs (13.5%), proving quality and cost-efficiency are positively correlated. The "B" tier (87% of suppliers) is the bulk of the business — targeted improvement here yields the biggest ROI. C-tier pays 3x the freight of A-tier (38.1% vs 13.5%).

---

## Executive Recommendations

1. **Volume reallocation:** Shift 20% of Exit-quadrant volume to Star suppliers → improves on-time by ~5pp, reduces freight by ~5%
2. **Supplier diversification program:** Target categories where top-1 share > 50% AND revenue > 50K BRL (office_furniture, home_appliances_2, small_appliances)
3. **Freight renegotiation:** Electronics and furniture/decor categories — combined savings potential > 100K BRL
4. **Performance improvement plans:** 93 C-tier suppliers need structured coaching or gradual phase-out timeline
5. **Consistency-focused SLAs:** Stop measuring just "average delivery days" — require suppliers to report CV alongside speed targets
