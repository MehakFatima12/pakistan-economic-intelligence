# 🇵🇰 Pakistan Economic Pulse

An end-to-end data analytics project tracking Pakistan's macroeconomic conditions — inflation, currency depreciation, fuel prices, and remittance inflows — from 2010 to 2026. Built as a full pipeline: **Python (cleaning & EDA) → MySQL (analysis) → Power BI (dashboard)**.

## 📌 Project Overview

Pakistan's economy has gone through significant volatility over the past 16 years — currency devaluation, high inflation, and energy price shocks. This project asks:

> **How do macroeconomic shocks ripple through Pakistan's economy, and when was economic stress at its highest?**

The dashboard tells this as a connected story across four pages: what happened → how did currency and external flows move → how did cost pressure evolve → when did these combine into peak economic stress.

## 🗂️ Data Source

Raw data collected from **SBP EasyData** (State Bank of Pakistan), covering:
- Inflation (YoY %)
- USD/PKR exchange rate
- Remittance inflows (Million USD)
- Petrol prices (PKR/L)

Monthly granularity, **2010–2026** (198 records).

## 🔧 Pipeline

### 1. Python — Data Cleaning & EDA
- Cleaned and merged five raw datasets in pandas
- Handled a CPI base-year discontinuity by splitting the inflation series into two date ranges before merging
- Built a unified master dataset with derived time fields (Year, Quarter, Fiscal Year)
- Performed exploratory data analysis with eight visualizations to understand distributions and trends before moving to SQL

### 2. MySQL — Analysis Layer
Over 30 SQL queries covering:
- Aggregations (yearly/quarterly averages, totals)
- Window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`, `LAG`/`LEAD`, rolling averages)
- CTEs for multi-step analysis (top-N years, above-average filtering)
- `CASE`-based categorization (inflation severity, currency trend direction)
- A custom **Economic Stress Index** — a min-max normalized composite metric
- A production view (`vw_powerbi_economic_dashboard`) feeding the dashboard directly

**Economic Stress Index formula:**
```
Stress Index = (USD_PKR_normalized × 0.40) 
             + (Inflation_normalized × 0.30) 
             + (Petrol_Price_normalized × 0.30)
             × 100
```
Each component is min-max normalized (0–1) across the full dataset before weighting. Weights reflect currency depreciation's outsized role in driving broader cost pressure in an import-dependent economy.

> **Note on scope:** Remittances are intentionally excluded from the Stress Index. Unlike currency, inflation, and fuel prices — which are direct cost/pressure drivers — remittances act as a *stabilizing buffer* rather than a stressor. They're tracked separately (Page 2) as a resilience indicator instead of being force-fit into a formula measuring economic pressure.

### 3. Power BI — Dashboard
A four-page report connected via MySQL:

| Page | Focus | Key Visuals |
|---|---|---|
| **1. Overview** | Headline snapshot | KPI cards, normalized macro snapshot, stress trend, color-coded yearly stress timeline |
| **2. Currency & Flows** | Currency & remittances | USD/PKR trend, remittance trend, YoY growth, USD/PKR vs. Remittances scatter (r = 0.86) |
| **3. Cost Pressure** | Inflation & fuel | Inflation trend, petrol trend, Inflation vs. Petrol (r = 0.45), USD/PKR vs. Petrol (r = 0.94) |
| **4. Stress Intelligence** | Composite analysis | Stress Index area chart, driver contribution breakdown, average driver share donut, top 10 highest-stress months |

## 📊 Key Findings

- **USD/PKR and petrol prices are almost perfectly linked (r = 0.94)** — the strongest, most consistent relationship in the dataset, reflecting Pakistan's fuel-import dependency.
- **Inflation has broader drivers than fuel alone (r = 0.45 with petrol)** — cost pressure isn't explained by energy prices in isolation.
- **2023 was the peak-stress year** — inflation hit 38% (May 2023) alongside USD/PKR crossing 285+, pushing the Stress Index into "Severe" territory for the first time in the dataset.
- **Currency was the dominant stress driver**, contributing a larger average share to the composite index than its assigned 40% weight would suggest — currency volatility disproportionately drives overall economic stress.
- **Remittances stayed resilient through the 2023 crisis**, reinforcing their role as an external buffer rather than a stress amplifier.
- USD/PKR and remittances show a positive statistical association (r = 0.86), but both are long-term upward trends over 16 years — this is **not treated as a causal relationship** without further lag analysis.

## 🛠️ Tech Stack
- **Python**: pandas (cleaning, merging, derived fields), matplotlib/seaborn (EDA)
- **MySQL**: window functions, CTEs, views
- **Power BI**: DAX measures, custom correlation calculations, conditional formatting, multi-page navigation

## 📁 Repository Structure
```
├── data/
│   └── master_dataset.csv
├── sql/
│   └── Economic_Analysis_SQL_Project.sql
├── notebooks/
│   └── cleaning_and_eda.ipynb
├── dashboard/
│   └── pakistan_economic_pulse.pbix
└── README.md
```

## 🔗 Related Project
This project's inflation data is reused in **[Household Budget vs. Official Inflation]**, which asks a follow-up question: does national CPI actually reflect what a typical Pakistani household experiences?

---
*Built by Mehak as part of a self-directed data analyst portfolio (Excel → SQL → Power BI → Python).*
