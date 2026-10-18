---
name: jt-momentum-replication
description: Run and audit the integrated Stata 18 Jegadeesh–Titman monthly momentum workflow for Tables I–III, including daily Scholes–Williams beta sorting for Table III.
---

# Reusable Skill: Jegadeesh–Titman Momentum Replication

## Goal

Run and audit the integrated Stata 18 workflow for Tables I–III, then inspect the exported tables and logs. Tables I and II use stock-level monthly CRSP data; Table III uses daily stock data for the Scholes–Williams beta sort.

## Run

From the repository root in Stata 18:

```stata
do "code/stata/00_master.do"
```

The master runs:

1. code/stata/01_prepare_monthly_factors.do
2. code/stata/03_table1.do
3. code/stata/04_table2.do
4. code/stata/02_estimate_sw_beta.do
5. code/stata/03_table3_daily_beta.do

## Source monthly CSV

The supplied stock-level source is `data/raw/monthly_stock.csv` (reported coverage 2000m1–2025m12), with `PERMNO`, `YYYYMM`, `MthRet`, `MthCap`, and `SecuritySubType` among its columns. See `data/raw/README.md` and `data/processed/README.md` for local data handling and variable contracts. The existing Stata master consumes the processed `.dta` input; it does not import the raw CSV directly.

## Required local inputs

- data/processed/crsp_monthly_clean_base.dta
- data/processed/crsp_daily_common_base_2000_2025.dta
- Either data/raw/F-F_Research_Data_Factors.CSV (header row 3) or data/raw/F-F factors and RF.csv (header row 1)

See references/input-output-contract.md for fields and units. Never commit restricted CRSP/course data or archives.

SPY_GLD_monthly_prices.csv is an ETF price file and cannot replace the stock-level monthly panel needed for momentum deciles. Do not claim Tables I and II can be generated from that file alone.

## Expected outputs

- outputs/tables/JT_TableI.csv
- outputs/tables/JT_TableII.csv
- outputs/tables/JT_TableIII_PanelA_daily_beta.csv
- outputs/tables/JT_TableIII_PanelB_daily_beta.csv
- outputs/logs/JT_full_workflow.log

Table I uses equal-weighted P1–P10 and WML returns for J/K in 3, 6, 9, and 12 months, overlapping cohorts, and Newey–West lag K−1. Table II summarizes J=K=6 and uses monthly Mkt-RF as a market-excess-return proxy. Table III uses daily Scholes–Williams beta estimated from the prior calendar year and a capitalization-weighted daily market proxy.

## Validation checklist

Before treating estimates as final:

- Run the master script locally in Stata 18 and inspect the complete log.
- Confirm input keys are unique (PERMNO/month and PERMNO/date) and return/factor units are correct.
- Verify factor merge coverage and the monthly sample range.
- Confirm Table I has all 16 J/K combinations and P1–P10/WML rows.
- Confirm Table II has P1–P10/WML rows and sensible market-model estimates.
- Confirm Table III has all expected samples/groups and decile/WML rows.
- Inspect missing months, observation counts, beta merge timing and the daily market proxy.
- Compare modern-sample estimates with the original paper while documenting sample-period and market-proxy differences.

The code has not been run against the user's local licensed data in this environment. Do not describe outputs as validated until a local run succeeds and the checks above pass.
