# Supplier Performance & Procurement Analytics

## Project Overview

An end-to-end supplier evaluation and procurement analytics framework built on Google BigQuery, analyzing 100K+ e-commerce orders across 3,000+ suppliers to optimize procurement decisions, reduce supply chain risk, and identify cost savings opportunities.

**Platform:** Google BigQuery  
**Dataset:** Brazilian e-commerce marketplace (Olist — public dataset)  
**Scale:** 99,441 orders | 112,650 order items | 3,095 sellers | 32,951 products

---

## Business Context

A mid-size e-commerce marketplace needs to:
1. Evaluate supplier reliability and quality at scale
2. Identify procurement concentration risks before they become supply disruptions
3. Optimize logistics costs without sacrificing delivery performance
4. Build a data-driven supplier tiering system for strategic decisions

---

## Analytical Modules

| Module | Focus Area | Key Deliverable |
|--------|-----------|-----------------|
| 1 | Data Model | `supplier_master` view — 20+ KPIs per supplier |
| 2 | Reliability Matrix | 4-quadrant classification (Star/Reliable/Risky/Exit) |
| 3 | Kraljic Portfolio Matrix | Strategic category segmentation for procurement |
| 4 | Lead Time Variability | Risk scoring by delivery consistency (CV analysis) |
| 5 | Supplier Concentration | HHI index + single-source dependency identification |
| 6 | Cost Optimization | Freight benchmarking by route and category |
| 7 | Supplier Scorecard | Weighted composite score (5 dimensions) |

---

## Key Findings

### Supplier Reliability (Module 2)
- **31% of suppliers classified as "Exit" candidates** — yet they generate the most revenue (4.3M BRL), indicating deep dependency on underperformers
- "Star" suppliers are under-utilized (avg 61.5 orders vs. 92.6 for "Exit" tier)
- Clear opportunity to shift volume from Exit → Star suppliers

### Procurement Risk (Module 5)
- Marketplace-level HHI = 43.74 (highly competitive overall)
- **Category-level concentration is critical:** 15 categories have HHI > 2,500 (highly concentrated)
- Office furniture: 70% of revenue depends on a single supplier (186K BRL at risk)
- 9 out of 15 analyzed categories have top-3 suppliers controlling 100% of volume

### Delivery Consistency (Module 4)
- **83% of suppliers are in High or Critical risk tiers** (CV > 50%)
- $11M BRL in revenue flows through suppliers with unpredictable delivery times
- Critical risk suppliers have the MOST orders (avg 94.1) — volume drives inconsistency

### Cost Optimization (Module 6)
- **215K BRL in identified freight savings** if all categories benchmark to 20% freight ratio
- Electronics category: 42.4% freight-to-revenue ratio (critical — logistics eating margin)
- Furniture/decor: largest absolute savings opportunity (79.9K BRL)
- State pattern: São Paulo (763 sellers) has only 91.2% on-time rate despite being the logistics hub

### Supplier Scorecard (Module 7)
- Only **5% of suppliers earn "Preferred" status** — they also have the lowest freight costs (13.5%)
- Quality and cost-efficiency are positively correlated — best suppliers are cheapest
- 93 suppliers (8%) in "Conditional" tier paying 38.1% freight — 3x the preferred tier rate

---

## Technical Skills Demonstrated

- **Google BigQuery:** Complex multi-CTE queries, window functions, statistical functions (STDDEV, APPROX_QUANTILES, PERCENT_RANK)
- **Data Modeling:** Dimensional design, aggregated master views, normalized scoring
- **Supply Chain Analytics:** Kraljic matrix, HHI concentration index, coefficient of variation, ABC classification
- **Statistical Methods:** Min-max normalization, weighted composite scoring, percentile ranking
- **Business Framing:** Translating analytical findings into actionable procurement recommendations

---

## Project Structure

```
├── README.md
├── sql/
│   ├── 01_supplier_master_view.sql
│   ├── 02_reliability_matrix.sql
│   ├── 03_kraljic_matrix.sql
│   ├── 04_lead_time_variability.sql
│   ├── 05_supplier_concentration.sql
│   ├── 06_cost_optimization.sql
│   └── 07_supplier_scorecard.sql
└── analysis/
    └── findings_summary.md
```

---

## How to Reproduce

1. Load the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into BigQuery
2. Create a dataset named `supplier_procurement_analytics`
3. Run SQL scripts in order (01 → 07)
4. Module 01 creates the foundation view; Modules 02–07 are independent analytical queries

---

## About

Built by Andy Yin — Supply Chain Data Specialist with 10+ years of experience in data warehouse engineering. This project demonstrates equivalent analytical approaches to real-world supplier management challenges using public data, due to confidentiality agreements with current employer.

**Contact:** [LinkedIn](https://www.linkedin.com/in/andy900210) | [GitHub](https://github.com/andy900210)
