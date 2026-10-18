# Stata workflow

The primary Table III route uses **daily Scholes–Williams beta**. The monthly rolling-beta prototype is not called by the master script.

## Run

From the repository root in Stata 18:

\`\`\`stata
do "code/stata/00_master.do"
\`\`\`

The master runs:

1. \`01_prepare_monthly_factors.do\` — imports monthly Fama–French Mkt-RF and RF.
2. \`02_estimate_sw_beta.do\` — constructs a daily market-return proxy and estimates annual Scholes–Williams beta by PERMNO-year.
3. \`03_table3_daily_beta.do\` — uses the prior calendar year's beta for beta terciles, forms overlapping six-month momentum portfolios, and exports Table III-style Panels A and B.

## Required local inputs

- \`data/processed/crsp_monthly_clean_base.dta\`
- \`data/processed/crsp_daily_common_base_2000_2025.dta\`
- \`data/raw/F-F_Research_Data_Factors.CSV\`

CRSP/course data may be restricted. Keep the data on your own machine; commit only code, documentation, and permitted derived outputs.

## Method choices and limitations

- Daily market proxy: lagged-capitalization-weighted return from the supplied CRSP ordinary-stock sample; not guaranteed to equal the original CRSP value-weighted index.
- Beta uses daily stock returns and previous/current/next observed trading-day market returns within each calendar year.
- Formation month in year Y is sorted using beta estimated in year Y-1 to avoid same-year look-ahead.
- Six-month formation return compounds months t-6 through t-1; holding months are t through t+5.
- Overlapping formation cohorts are averaged within each holding month.
- French factors are converted from percentage points to decimals.
- Newey–West standard errors use five lags.
