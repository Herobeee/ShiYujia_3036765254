# Jegadeesh & Titman (1993): Momentum Replication

**Project:** modern-sample methodological replication and size-heterogeneity extension.  
**Paper:** Narasimhan Jegadeesh and Sheridan Titman (1993), “Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency,” *Journal of Finance*, 48(1), 65–91.

## Complete Stata workflow

Run from the repository root in Stata 18:

```stata
do "code/stata/00_master.do"
```

The master runs the following modules:

1. `01_prepare_monthly_factors.do` — imports monthly Fama–French Mkt-RF and RF, normalizes names and converts percentage points to decimals.
2. `03_table1.do` — constructs equal-weighted momentum deciles for J = 3, 6, 9, 12 and K = 3, 6, 9, 12-month overlapping holding strategies. Newey–West lags equal K−1.
3. `04_table2.do` — summarizes the J=K=6 portfolios, including mean returns, HAC t-statistics, market-model alpha/beta and average formation capitalization.
4. `02_estimate_sw_beta.do` — constructs a daily lagged-capitalization-weighted market proxy and estimates annual Scholes–Williams beta by stock.
5. `03_table3_daily_beta.do` — produces Table III-style size/beta sorts using the prior calendar year's daily Scholes–Williams beta.

## Source data and required local inputs

The stock-level monthly source supplied for this project is `data/raw/monthly_stock.csv` (reported coverage: January 2000–December 2025). Its columns include `PERMNO`, `YYYYMM`, `MthRet`, `MthCap`, and `SecuritySubType`, plus CRSP market-return fields. See [`data/raw/README.md`](data/raw/README.md) for the source-field notes and local-only data rules.

**Workflow boundary:** the current Stata master still consumes the processed monthly `.dta` file listed below; it does not directly import `monthly_stock.csv`. Preserve the existing Stata analysis as the authoritative workflow; do not assume a raw-to-results run is available until that local processed input has been prepared and checked.

## Required local inputs

- `data/processed/crsp_monthly_clean_base.dta` — `PERMNO`, `month`, `MthRet`, `MthCap`, `SecuritySubType`
- `data/processed/crsp_daily_common_base_2000_2025.dta` — `PERMNO`, `date`, `DlyRet`, `DlyPrevCap`
- Either `data/raw/F-F_Research_Data_Factors.CSV` (official layout, header row 3) or `data/raw/F-F factors and RF.csv` (cleaned layout, header row 1), with a YYYYMM key plus Mkt-RF and RF columns.

Stock returns are assumed to be decimals; factor CSV values are assumed to be percentage points and divided by 100. Verify source units before running.

**Important:** `SPY_GLD_monthly_prices.csv` contains SPY/GLD ETF prices, not stock-level monthly CRSP returns. It cannot by itself form the ten stock momentum deciles in Tables I and II. `daily_stock.csv` must be mapped and validated into the documented daily schema before it can be used by the Table III beta module.

**Do not upload restricted CRSP/course data, source archives, or processed licensed datasets to this public repository.**

## Outputs

- `outputs/tables/JT_TableI.csv` — Table I-style mean returns, Newey–West t-statistics and sample sizes for all J/K strategies and P1–P10/WML.
- `outputs/tables/JT_TableII.csv` — J=K=6 portfolio summary and market-model estimates.
- `outputs/tables/JT_TableIII_PanelA_daily_beta.csv` — Table III-style raw returns and WML by sample/group.
- `outputs/tables/JT_TableIII_PanelB_daily_beta.csv` — Table III-style market-model alpha estimates.
- `outputs/logs/JT_full_workflow.log` — master run log.

Intermediate .dta files and logs should remain local unless their contents and applicable licence permit redistribution.

## Validation status

The connected scripts have not been executed against the user's local data in this environment. Treat them as integrated code, not validated final estimates, until they run successfully in Stata 18. Check factor headers and units, uniqueness of PERMNO/month and PERMNO/date keys, return units, merge coverage, sample dates, observation counts and output rows. The daily market proxy is a lagged-capitalization-weighted proxy, not guaranteed to equal the original CRSP value-weighted index. This is a modern-sample methodological replication, not exact numerical reproduction of the original historical sample.

## Reference

Jegadeesh, N., & Titman, S. (1993). Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency. *The Journal of Finance*, 48(1), 65–91. https://doi.org/10.1111/j.1540-6261.1993.tb04702.x
