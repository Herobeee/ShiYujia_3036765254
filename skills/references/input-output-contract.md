# Input and Output Contract

## Local inputs

| Path | Role | Expected fields |
|---|---|---|
| `data/processed/crsp_monthly_clean_base.dta` | Stock-level monthly formation/holding returns and capitalization | `PERMNO`, `month`, `MthRet`, `MthCap`, `SecuritySubType` |
| `data/processed/crsp_daily_common_base_2000_2025.dta` | Daily stock returns and lagged capitalization for market proxy and Scholes–Williams beta | `PERMNO`, `date`, `DlyRet`, `DlyPrevCap` |
| `data/raw/F-F_Research_Data_Factors.CSV` | Official monthly factor CSV, header row 3 | First column YYYYMM, market-excess and risk-free columns |
| `data/raw/F-F factors and RF.csv` | Cleaned monthly factor CSV, header row 1 | First column YYYYMM, `mktrf` or `mkt_rf`, and `rf` |

Factor values are assumed to be percentage points and divided by 100. Stock returns are assumed to be decimals. Verify these conventions before running.

`SPY_GLD_monthly_prices.csv` is an ETF price file, not the stock-level monthly panel required to form momentum deciles. It is not a substitute for `crsp_monthly_clean_base.dta`.

## Generated files

| Path | Contents |
|---|---|
| `outputs/tables/JT_TableI.csv` | Mean monthly returns, Newey–West t-statistics and N for P1–P10/WML across all 16 J/K combinations |
| `outputs/tables/JT_TableII.csv` | J=K=6 mean returns, HAC t-statistics, market-model alpha/beta and average formation capitalization |
| `outputs/tables/JT_TableIII_PanelA_daily_beta.csv` | Table III-style raw returns and WML by sample/group |
| `outputs/tables/JT_TableIII_PanelB_daily_beta.csv` | Table III-style market-model alpha estimates |
| `outputs/logs/JT_full_workflow.log` | Full master workflow log |
| `data/processed/intermediate/jt_table1_portfolio_series.dta` | Local monthly series for J/K strategies, deciles, returns and formation capitalization |
| `data/processed/intermediate/jt_factors_monthly.dta` | Normalized monthly Mkt-RF/RF series |

## Method and interpretation notes

- Table I uses equal-weighted deciles, overlapping formation cohorts and Newey–West lag K−1 for K-month holding strategies.
- Table II market-model estimates use monthly Mkt-RF as the market-excess-return proxy. WML is a long-short return spread, so RF is not subtracted a second time.
- Table III uses daily Scholes–Williams beta estimated on prior-calendar-year daily observations. Its daily market return is a lagged-capitalization-weighted proxy, not guaranteed to equal the original CRSP value-weighted index.
- The modern sample is not the original 1965–1989 sample; describe it as a modern-sample methodological replication, not exact numerical reproduction.

## Data governance

Do not commit CRSP extracts, course data archives, or restricted processed datasets. Before sharing outputs or logs, check redistribution permission and remove sensitive local paths or restricted records.
