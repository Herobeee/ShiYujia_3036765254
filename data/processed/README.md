# Processed analysis inputs (local only)

For the primary Stata 18 daily Scholes–Williams workflow, keep these authorized inputs in this folder on your local machine:

- `crsp_monthly_clean_base.dta`
- `crsp_daily_common_base_2000_2025.dta`

The monthly file supplies stock-level formation and holding-period data; the daily file supplies daily stock returns and lagged market capitalization for the Scholes–Williams beta workflow. Expected variables are documented in `skills/references/input-output-contract.md`.

Do not commit these datasets unless the relevant CRSP/course licence explicitly permits redistribution. The public repository intentionally contains instructions rather than restricted data.

The legacy Python monthly-portfolio workflow uses different input filenames. It is separate from the primary Stata Table III workflow and is documented as legacy code.
