# Processed analysis inputs (local only)

These files are prepared locally from authorized source data and are intentionally ignored by Git. Do not commit licensed data to the public repository.

## Monthly stock panel

Required local path: `crsp_monthly_clean_base.dta`

Required variables:
- `PERMNO`: numeric security identifier.
- `month`: Stata monthly date (%tm recommended).
- `MthRet`: monthly stock return in decimal units.
- `MthCap`: monthly capitalization.
- `SecuritySubType`: security subtype; the current analysis uses `COM`.

The corresponding raw source is `../raw/monthly_stock.csv`, reported to cover January 2000–December 2025. Convert `YYYYMM` into a Stata monthly `month` key. Before using the processed file, verify sample coverage, missing keys, return units, common-stock filtering, and uniqueness of `PERMNO month`. Do not silently drop duplicate key rows without inspecting the source rows and any available security/share-type fields.

## Daily stock panel

Required local path: `crsp_daily_common_base_2000_2025.dta`

Required variables: `PERMNO date DlyRet DlyPrevCap`. `date` is a Stata daily date and returns are expected in decimal units. This input supports the daily Scholes–Williams beta workflow for Table III.

## Outputs and privacy

The existing master script consumes these processed datasets; it does not import `monthly_stock.csv` directly. Keep the existing Stata analysis authoritative and do not claim a raw-to-results run is complete until the local processed inputs have been prepared and validated in Stata 18.

Non-restricted summary tables may be placed under `outputs/tables/` only after checking applicable data-sharing rules. Never commit restricted raw or processed datasets.
