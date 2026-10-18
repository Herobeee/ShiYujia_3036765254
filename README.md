# Jegadeesh & Titman (1993): Momentum Replication

**Project:** modern-sample momentum replication and size-heterogeneity extension.  
**Paper:** Narasimhan Jegadeesh and Sheridan Titman (1993), “Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency,” *Journal of Finance*, 48(1), 65–91.

## Primary workflow

The primary Table III route is the **Stata 18 daily-data Scholes–Williams beta workflow** in `code/stata/`. The monthly rolling-beta/Python analysis is a retained legacy exploratory workflow, not the primary Table III method. Do not combine results from the two workflows unless their samples, portfolio definitions, and factor construction have been reconciled and documented.

The daily market-return proxy is a lagged-capitalization-weighted return built from the supplied ordinary-stock sample. It is not guaranteed to be identical to the original CRSP value-weighted index. This is a modern-sample methodological replication, not an exact numerical reproduction of the original historical sample.

## Run the Stata workflow

Use Stata 18 from the repository root:

```stata
do "code/stata/00_master.do"
```

The master script runs:

1. `code/stata/01_prepare_monthly_factors.do`
2. `code/stata/02_estimate_sw_beta.do`
3. `code/stata/03_table3_daily_beta.do`

Required local inputs:

- `data/processed/crsp_monthly_clean_base.dta`
- `data/processed/crsp_daily_common_base_2000_2025.dta`
- `data/raw/F-F_Research_Data_Factors.CSV`

The exact input fields and output contract are documented in [skills/references/input-output-contract.md](skills/references/input-output-contract.md). **Do not upload restricted CRSP/course data, source archives, or processed licensed datasets to this public repository.**

## Skill and optional Python tools

- [Reusable replication skill](skills/SKILL.md) explains the main workflow, expected outputs, and validation checks.
- [Input/output contract](skills/references/input-output-contract.md) documents the expected data fields, units, and data governance.
- `skills/scripts/plot_table3.py` creates figures from the CSVs exported by Stata. It does not estimate the model.
- `requirements-python-legacy.txt` contains optional dependencies for the retained legacy Python workflow and plotting helper. The primary estimation workflow uses Stata 18 and does not require Python packages.

After a successful Stata run, figures can be generated from the repository root:

```bash
python -m pip install -r requirements-python-legacy.txt
python skills/scripts/plot_table3.py
```

## Outputs

The connected Stata master currently generates Table III-style outputs:

- `outputs/tables/JT_TableIII_PanelA_daily_beta.csv`
- `outputs/tables/JT_TableIII_PanelB_daily_beta.csv`
- `outputs/logs/JT_daily_beta_workflow.log`

The plotting helper writes two figures under `outputs/figures/`. Intermediate `.dta` files and logs should remain local unless their contents and the applicable licence permit redistribution.

**Scope note:** the currently connected Stata master runs Table III. Do not claim Tables I and II are reproduced by this master unless their final scripts are connected and tested.

## Validation status

The committed Stata scripts have not been executed against the user's local licensed data in this environment. Before describing outputs as final, run the workflow in Stata 18 and check factor-file headers and units, uniqueness of date/PERMNO-month keys, beta merge coverage and timing, market-proxy construction, sample dates, return units, missing months, observation counts, and differences from the assigned paper tables. The plotting script also requires successful, non-empty Table III CSV outputs.
