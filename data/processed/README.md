# Processed Data — Not Included in This Repository

The original raw datasets and the cleaned/processed datasets used for this project are **too large to upload to this GitHub repository**. GitHub also imposes file-size limits, so these data files are intentionally kept on the researcher's local machine rather than committed here.

This folder therefore contains documentation only; the absence of the `.dta` files is intentional and does not mean the data-processing step was omitted.

## Files expected locally

For the primary Stata 18 daily Scholes–Williams workflow, place the following authorized files in this folder on your local machine:

- `crsp_monthly_clean_base.dta`
- `crsp_daily_common_base_2000_2025.dta`

The Fama–French monthly factor file is expected at `data/raw/F-F_Research_Data_Factors.CSV`.

These files are required to run the analysis, but they are not included in the public repository because of their size and, where applicable, data-licensing restrictions. Obtain the source data through the authorized provider/course access and reproduce the cleaning steps locally. Do not upload the original or cleaned CRSP/course data to this public repository unless redistribution is explicitly permitted.

## How to run

Once the required local files are in place, open Stata 18 from the repository root and run:

```stata
do "code/stata/00_master.do"
```

See [the input/output contract](../../skills/references/input-output-contract.md) for the expected variables, date formats, units, and generated outputs.

## Reproducibility note

The repository provides analysis code and documentation, not the large source datasets. A successful reproduction requires access to the appropriate data locally. The data's omission is a storage/licensing constraint, not a claim that the data are unnecessary.
