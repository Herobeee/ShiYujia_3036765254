# Input and Output Contract

This document is the schema reference for the reusable skill in `skills/SKILL.md`.

## Local inputs for the primary Stata workflow

| Path | Role | Expected fields used by the committed scripts |
|---|---|---|
| `data/processed/crsp_monthly_clean_base.dta` | Monthly stock returns and market capitalization for portfolio formation/holding returns | `PERMNO`, `month`, `MthRet`, `MthCap`, `SecuritySubType` |
| `data/processed/crsp_daily_common_base_2000_2025.dta` | Daily stock returns and lagged market capitalization for the market proxy and Scholes–Williams beta | `PERMNO`, `date`, `DlyRet`, `DlyPrevCap` |
| `data/raw/F-F_Research_Data_Factors.CSV` | Monthly Fama–French market excess return and risk-free rate | CSV header must expose `Mkt_RF` and `RF`; the current import expects variable names on row 3 |

The Stata code assumes Stata monthly dates for `month` and daily dates for `date`. Factor values in the French CSV are treated as percentage points and divided by 100 in `01_prepare_monthly_factors.do`. Stock returns are assumed to be decimal returns. Verify these conventions against the official source documentation before running.

## Generated files

| Path | Contents |
|---|---|
| `outputs/tables/JT_TableIII_PanelA_daily_beta.csv` | Portfolio raw-return means, t-statistics, and observation counts by sample and decile, including P10−P1 |
| `outputs/tables/JT_TableIII_PanelB_daily_beta.csv` | Market-model alpha estimates, t-statistics, and observation counts by sample and decile, including P10−P1 |
| `outputs/figures/table3_panelA_raw_returns.png` | Figure of Panel A raw-return estimates with approximate 95% intervals inferred from the reported t-statistics |
| `outputs/figures/table3_panelB_alphas.png` | Figure of Panel B alpha estimates with approximate 95% intervals inferred from the reported t-statistics |
| `outputs/logs/JT_daily_beta_workflow.log` | Stata run log |

The figure script visualizes already-exported estimates. It does not recalculate portfolio returns, standard errors, or regressions. Confidence intervals derived from t-statistics are visual approximations; the CSV tables remain the primary numerical record.

## Data governance

- Do not commit CRSP extracts, course data archives, or restricted processed datasets to the public repository.
- Keep raw and processed inputs local unless the applicable licence explicitly permits redistribution.
- Before committing outputs or logs, check whether they reveal restricted records, identifiers, local file paths, or other information that should remain private.
- Public documentation should explain the authorized data-access route and expected local file names without redistributing the data themselves.

## Scope boundary

The currently connected Stata master workflow generates Table III-style outputs. It does not currently run Tables I and II. Do not imply that those tables are automatically reproduced unless their final analysis scripts are added and tested.
