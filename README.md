# Jegadeesh & Titman (1993): Momentum Replication

**Student project:** modern-sample replication and size-heterogeneity extension  
**Paper:** Narasimhan Jegadeesh and Sheridan Titman (1993), “Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency,” *Journal of Finance*, 48(1), 65–91.

## Research question

Do portfolios formed from past winners outperform portfolios formed from past losers, after controlling for market exposure? Does the estimated momentum alpha vary with firm size?

## Scope and sample

This project applies the market-model approach to monthly portfolio returns over **December 2001–December 2025**, consistent with the course's default modern sample period. It is a modern-sample application of the paper's methodology, not an exact numerical reproduction of the original paper's historical sample.

The core output is a Table III, Panel B-style set of market-model alphas for portfolios P1–P10 and the winner-minus-loser (WML) spread, for the full sample and three size groups. Newey–West/HAC standard errors use five lags.

The independent extension tests whether the WML market-model alpha differs across small-, medium-, and large-size groups. Pairwise tests estimate the intercept in the time-series regression of the difference between two size-group WML returns on the market excess return, using the same HAC lag length.

## Repository layout

- `data/raw/`: local raw inputs or instructions for obtaining licensed course data. **Do not commit restricted CRSP/course data.**
- `data/processed/`: local analysis-ready input files. Do not publish licensed or restricted data; see the folder README.
- `code/run_all.py`: single Python entry point for the reported regressions, extension tests, CSV tables, and figures.
- `outputs/tables/`: generated result tables.
- `outputs/figures/`: generated figures.
- `skills/SKILL.md`: reusable workflow and validation checklist.
- `AI_USE_DISCLOSURE.md`: AI-use and verification disclosure.
- `report.pdf`: preliminary report draft is included; it must be updated after running the workflow against the final approved inputs and reviewing the generated extension tests. The more editable source draft is `report_draft.md`.

## Required input files

Place these files in `data/processed/` on your own computer before running the script:

1. `JT_TableII_returns_with_market.dta` — monthly full-sample portfolio returns P1–P10, WML, `mkt_return`, and `holding_month`.
2. `JT_TableIII_size_panelA_monthly.dta` — monthly size-group portfolio returns, including `sizegrp` (1=small, 2=medium, 3=large), P1–P10, WML, and `holding_month`.
3. `FF_monthly_factors.dta` — monthly `rf_decimal` and `holding_month`. The script takes the market return from the full-sample portfolio file and merges the risk-free rate by month.

These are input requirements, not files currently included in the public repository. Follow the course download instructions and the included data dictionaries; keep the course-provided folder names and source filenames unchanged where required. Do not upload raw or processed data if the course licence prohibits redistribution.

## Reproduce the outputs

Use Python 3.10 or later. From the repository root:

```bash
python -m pip install -r requirements.txt
python code/run_all.py
```

The script stops with an actionable error if an input file is missing. It does not silently substitute data or hard-code the results. On a successful run, it writes the core alpha table, the size-heterogeneity tests, summary statistics, and PNG figures to `outputs/`.

## Validation and interpretation

- Confirm the sample covers December 2001–December 2025 where the input data permit.
- Confirm portfolio and factor returns are stored as decimals, not percentage points.
- Check that the market return and risk-free rate are merged one-to-one by month.
- Interpret WML as winner return minus loser return; do not subtract the risk-free rate from WML a second time.
- Report that HAC standard errors use five lags.
- Compare the sign and qualitative pattern with Jegadeesh and Titman (1993), while explaining the different sample period and data construction.
- Do not claim that size-group alphas differ statistically unless the extension's formal pairwise tests support that conclusion.

## Current status

The repository contains the reproducibility code and documentation scaffold. The licensed input datasets are intentionally not committed. The final PDF report and generated outputs must be refreshed after the required inputs are placed locally and the workflow is run and checked.
