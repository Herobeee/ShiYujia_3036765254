# Reusable Skill: Momentum Table III-Style Replication

## Purpose

Generate a modern-sample market-model alpha table for P1–P10 and WML, summarize the inputs, create diagnostic figures, and test whether WML alphas differ across size groups.

## Inputs

Place the following licensed/approved analysis files in data/processed/ locally:
- JT_TableII_returns_with_market.dta
- JT_TableIII_size_panelA_monthly.dta
- FF_monthly_factors.dta

Never commit restricted course or CRSP datasets to a public repository. Read the data dictionary and course download instructions first.

## Workflow

1. Install dependencies with python -m pip install -r requirements.txt.
2. Run python code/run_all.py from the repository root (the script also resolves paths relative to itself).
3. Confirm that month keys are Stata monthly integers and that the period is December 2001 through December 2025.
4. Confirm that portfolio returns, market returns, and risk-free rates are decimals.
5. Confirm one observation per month in the full-sample portfolio and factor files, and one observation per month and size group in the size file.
6. Confirm that the market-return series is taken from the full-sample return input and the risk-free rate is merged by month.
7. Review outputs/tables/core_replication_alphas.csv, size_heterogeneity_tests.csv, and summary_statistics.csv.
8. Review the 95% HAC interval figures in outputs/figures/.
9. Cross-check the results against independent Stata regressions before using them in the report.

## Statistical specifications

For each P1–P10 portfolio, regress portfolio excess returns on market excess returns: R_p - RF = alpha + beta (R_m - RF) + error.

For WML, regress the winner-minus-loser spread on market excess return. Do not subtract RF from WML again. All regressions use OLS coefficients with Newey–West/HAC standard errors using five lags.

The independent extension estimates the intercept in the regression of the pairwise difference between two size-group WML return series on market excess return. This intercept is the difference in their market-model alphas under a common time index. Report the estimate and HAC t-statistic; do not state that two groups differ unless the formal test supports it.

## Outputs

The Python entry point writes:
- Core portfolio alphas and HAC inference.
- Pairwise size-group WML alpha-difference tests.
- Descriptive statistics.
- Full-sample alpha confidence-interval figure.
- WML alpha comparison figure.

## Troubleshooting

- Missing-input errors are intentional and identify the expected local path.
- Merge errors indicate duplicate monthly keys or a mismatch between input formats; fix the input construction, not the results.
- Missing RF or market returns must be resolved from approved source data and documented.
- If the data use percentage points rather than decimals, convert units explicitly after verifying the source documentation. Do not infer units from the observed coefficient size alone.
