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

## Source data and required local inputs

The monthly stock-level source is `data/raw/monthly_stock.csv`, reported to cover January 2000–December 2025. Its supplied columns include `PERMNO`, `YYYYMM`, `MthRet`, `MthCap`, and `SecuritySubType`. See [`data/raw/README.md`](../../data/raw/README.md) for details.

The existing master script expects the processed `.dta` inputs below and does not import `monthly_stock.csv` directly. Keep the established analysis code unchanged and ensure the local processed file follows the documented contract before running.

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

- Table I includes 16 J/K combinations and P1–P10 plus WML; portfolios are equal-weighted and formation cohorts overlap. As a project-specific robustness choice, the six-month formation return is winsorized cross-sectionally within month at the 1st/99th percentiles; this is not attributed to the original JT procedure.
- Table II market-model estimates use monthly Fama–French Mkt-RF as the market-excess-return proxy, not the original CRSP value-weighted index.
- Table III daily market returns are a lagged-capitalization-weighted proxy from the supplied ordinary-stock sample.
- `SPY_GLD_monthly_prices.csv` is not a stock-level monthly CRSP return panel and cannot create momentum deciles by itself.
- Do not commit restricted CRSP/course data or processed licensed datasets to the public repository.

The scripts have not been run against the user's local licensed data in this environment. Inspect the log and verify merge keys, sample coverage, units, output row counts and table values before calling results final.
## Standalone Table III Panel B (size portfolios only)

`05_table3_panelB_size_capm.do` preserves the standalone size-group CAPM calculation for All, Small, Medium and Large portfolios. It estimates monthly excess portfolio returns on the market excess return using Newey–West standard errors with lag 5.

Run from the repository root:

```stata
do "code/stata/05_table3_panelB_size_capm.do"
```

This script expects the following **local-only intermediate files** (they are not committed to GitHub):

- `data/processed/intermediate/JT_TableII_returns_with_market.dta`: `holding_month`, `mkt_return`, `portret1`–`portret10`, `WML`.
- `data/processed/intermediate/JT_TableIII_size_panelA_monthly.dta`: `holding_month`, `sizegrp` (1=Small, 2=Medium, 3=Large), portfolio return variables and `WML`.
- `data/processed/intermediate/FF_monthly_factors.dta`: `holding_month`, `rf_decimal`.

It writes `outputs/tables/JT_TableIII_PanelB_size_only.csv` and `.dta`. This is a **standalone size-only output** and is not called by `00_master.do`; the integrated size/beta Table III workflow remains `03_table3_daily_beta.do`. The script is organized for repository use, but its output has not been independently rerun or validated in this environment.
