# Supplier Performance & Procurement Analytics

Supplier evaluation framework for an e-commerce marketplace — reliability scoring, concentration risk, and cost optimization. Built on Google BigQuery.

## Background

This project grew out of a simple question: if you have 3,000 suppliers, how do you decide which ones to grow, which to coach, and which to cut?

I used the same Olist Brazilian e-commerce dataset as my delivery performance project, but reframed it entirely from a procurement perspective. Instead of asking "are orders arriving on time?" I asked "which suppliers are creating the problems, and what would it cost to fix or replace them?"

The answer turned out to be uncomfortable: the worst-performing suppliers are also the highest-volume ones. They're too embedded to simply cut, which is exactly the kind of messy reality that makes procurement analytics valuable.

## Data

Same Olist dataset, different lens:
- 2,970 active sellers evaluated
- 112,650 order items with delivery tracking and customer reviews
- Analyzed across volume, revenue, delivery, quality, and cost dimensions

## What I Found

**31% of suppliers should be phased out** — but they generate the most revenue ($4.3M BRL). The "Exit" quadrant has higher average orders (92.6) than the "Star" quadrant (61.5). Classic "too big to fail" supplier dependency.

**The marketplace looks diversified until you drill into categories.** Overall HHI is 44 (extremely competitive). But at the category level, 15 out of 15 analyzed categories are "Highly Concentrated" — with top-3 suppliers controlling 100% in 9 of them. One furniture supplier going down takes $186K in revenue with it.

**83% of suppliers have unpredictable delivery times.** Average delivery days are similar across risk tiers (~11-12 days) — the problem isn't speed, it's consistency. A supplier delivering in 5 days one week and 25 the next is worse than one consistently at 15.

**$215K BRL in freight savings identified** by benchmarking all categories to a 20% freight-to-revenue ratio. Electronics is the worst offender at 42.4% — shipping costs nearly match product value.

**Quality and cost-efficiency are correlated, not traded off.** The top 5% of suppliers (by composite score) also have the lowest freight costs at 13.5%. The bottom tier pays 38% — nearly 3x more. Good suppliers are cheap; bad suppliers are expensive in every dimension.

## Modules

| # | What it does |
|---|-------------|
| 01 | `supplier_master` view — 20+ KPIs per seller in one row |
| 02 | Reliability Matrix — Star/Reliable/Risky/Exit quadrants |
| 03 | Kraljic Matrix — strategic category segmentation |
| 04 | Lead Time Variability — coefficient of variation risk scoring |
| 05 | Concentration Analysis — HHI and single-source dependency |
| 06 | Cost Optimization — freight benchmarking, savings quantification |
| 07 | Weighted Scorecard — 5-dimension composite supplier ranking |

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

## How to Run

1. Load the [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into BigQuery
2. Create a dataset named `supplier_procurement_analytics`
3. Run scripts in order — 01 builds the view, 02-07 are independent queries

## About

I built this to show what procurement analytics actually looks like beyond "rate your suppliers 1-5." Real supplier management means understanding concentration risk, delivery variability, cost structures, and how they interact. The Kraljic matrix and HHI analysis are frameworks I've used professionally — applied here to public data for demonstration purposes.

Andy Yin — [LinkedIn](https://www.linkedin.com/in/andy900210) | [GitHub](https://github.com/andy900210)
