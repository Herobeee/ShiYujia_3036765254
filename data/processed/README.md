# Processed analysis inputs (local only)

Before running python code/run_all.py, place these three analysis-ready Stata files in this folder on your local machine:

- JT_TableII_returns_with_market.dta
- JT_TableIII_size_panelA_monthly.dta
- FF_monthly_factors.dta

The expected variables and merge keys are documented in the root README and validated by code/run_all.py.

These files are not committed because the underlying course/CRSP data may be restricted. Keep them local unless the course licence explicitly authorizes redistribution. The Python workflow will stop with a clear message if a required file is absent.
