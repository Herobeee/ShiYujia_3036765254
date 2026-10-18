# Stata workflow

Run the integrated workflow from the repository root in Stata 18:

```stata
do "code/stata/00_master.do"
```

## Modules

1. `01_prepare_monthly_factors.do` — reads the official French factor CSV (header row 3) or cleaned `F-F factors and RF.csv` (header row 1), normalizes Mkt-RF/RF names and converts percentage points to decimals.
2. `03_table1.do` — builds monthly winner/loser deciles for J = 3, 6, 9, 12 and overlapping K = 3, 6, 9, 12-month strategies. It uses shifted calendar-month keys rather than `xtset`; Newey–West lag is K−1.
3. `04_table2.do` — uses the J=K=6 series and reports mean returns, mean-return HAC t-statistics, market-model alpha/beta and average formation capitalization.
4. `02_estimate_sw_beta.do` — builds a daily lagged-capitalization-weighted market proxy and estimates annual Scholes–Williams beta by PERMNO-year.
5. `03_table3_daily_beta.do` — produces Table III-style size/beta groups; formation month in year Y uses beta from year Y−1.

## Required local inputs

- `data/processed/crsp_monthly_clean_base.dta`: `PERMNO month MthRet MthCap SecuritySubType`
- `data/processed/crsp_daily_common_base_2000_2025.dta`: `PERMNO date DlyRet DlyPrevCap`
- One factor file:
  - `data/raw/F-F_Research_Data_Factors.CSV` (official layout; header row 3), or
  - `data/raw/F-F factors and RF.csv` (cleaned layout; header row 1).

The scripts assume stock returns are decimals and factor values are percentage points. Confirm this from source documentation before running.

## Outputs

- `outputs/tables/JT_TableI.csv`
- `outputs/tables/JT_TableII.csv`
- `outputs/tables/JT_TableIII_PanelA_daily_beta.csv`
- `outputs/tables/JT_TableIII_PanelB_daily_beta.csv`
- `outputs/logs/JT_full_workflow.log`

## Interpretation and limitations

- Table I includes 16 J/K combinations and P1–P10 plus WML; portfolios are equal-weighted and formation cohorts overlap.
- Table II market-model estimates use monthly Fama–French Mkt-RF as the market-excess-return proxy, not the original CRSP value-weighted index.
- Table III daily market returns are a lagged-capitalization-weighted proxy from the supplied ordinary-stock sample.
- `SPY_GLD_monthly_prices.csv` is not a stock-level monthly CRSP return panel and cannot create momentum deciles by itself.
- Do not commit restricted CRSP/course data or processed licensed datasets to the public repository.

The scripts have not been run against the user's local licensed data in this environment. Inspect the log and verify merge keys, sample coverage, units, output row counts and table values before calling results final.
