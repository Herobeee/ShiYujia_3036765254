# Jegadeesh & Titman (1993): Momentum Replication

**Student project:** modern-sample momentum replication and size-heterogeneity extension  
**Paper:** Narasimhan Jegadeesh and Sheridan Titman (1993), “Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency,” *Journal of Finance*, 48(1), 65–91.

## Primary methodology

The **primary Table III route is the daily-data Scholes–Williams beta approach**, implemented in \`code/stata/\`. The monthly rolling-beta version is an exploratory prototype and is not called by the Stata master script because it did not reproduce the intended Table III specification.

The daily-beta workflow constructs a daily value-weighted market-return proxy from the supplied CRSP ordinary-stock sample, estimates annual Scholes–Williams betas using lagged, contemporaneous, and leading market returns, and assigns each formation month the beta estimated in the prior calendar year. It then constructs six-month momentum portfolios and exports Table III-style raw-return and CAPM-alpha results.

**Important limitation:** the market proxy is built from the supplied stock sample and is not guaranteed to be identical to the original CRSP value-weighted index. This is a modern-sample methodological replication, not an exact numerical reproduction of the paper's historical sample.

## Stata workflow

From the repository root in Stata 18:

\`\`\`stata
do "code/stata/00_master.do"
\`\`\`

Run order:
1. \`code/stata/01_prepare_monthly_factors.do\`
2. \`code/stata/02_estimate_sw_beta.do\`
3. \`code/stata/03_table3_daily_beta.do\`

See [\`code/stata/README.md\`](code/stata/README.md) for inputs, assumptions, and validation checks.

## Required local inputs for the Stata workflow

- \`data/processed/crsp_monthly_clean_base.dta\`
- \`data/processed/crsp_daily_common_base_2000_2025.dta\`
- \`data/raw/F-F_Research_Data_Factors.CSV\`

Place licensed inputs locally using these paths or adjust the scripts consistently. **Do not commit restricted CRSP/course data** to this public repository.

## Existing Python workflow

\`code/run_all.py\` and the associated report files are retained as a separate earlier monthly-portfolio analysis. They are **not** the primary daily Scholes–Williams Table III workflow. Do not mix its results with the Stata daily-beta results unless the sample, portfolio definitions, and factor construction have been reconciled and documented.

## Outputs

The Stata workflow writes Table III-style output tables under \`outputs/tables/\` and a log under \`outputs/logs/\`. Intermediate datasets are written under \`data/processed/intermediate/\`. These generated outputs are not included in the repository by default, and licensed data should remain local.

## Validation status

The scripts have been organized and committed, but **have not been executed against the user's local licensed data in this environment**. Before treating results as final, run them in Stata 18 and check:
- factor-file headers and factor units;
- uniqueness of PERMNO-month and date keys;
- beta merge coverage and the prior-year timing convention;
- market-proxy construction and daily observation counts;
- portfolio return units, sample dates, missing months, and observation counts;
- differences from the assigned paper tables and the reasons for those differences.

Do not describe outputs as reproduced or validated until this local run completes successfully and its results have been reviewed.
