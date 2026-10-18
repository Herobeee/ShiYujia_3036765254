# Raw data instructions

The local stock-level monthly source file is **`monthly_stock.csv`**, reported to cover **January 2000–December 2025**. Keep it at `data/raw/monthly_stock.csv` on your own computer.

Its supplied header is:

`PERMNO, YYYYMM, MthCalDt, MthPrc, MthCap, MthRet, MthRetx, vwretd, vwretx, ewretd, ewretx, sprtrn, SecuritySubType`

Key fields for the existing monthly momentum analysis:
- `PERMNO`: security identifier.
- `YYYYMM`: calendar month key, e.g. `200001`.
- `MthRet`: monthly stock return.
- `MthCap`: monthly capitalization.
- `SecuritySubType`: security subtype; the current analysis uses `COM` common stocks.

The `vwretd`, `vwretx`, `ewretd`, `ewretx`, and `sprtrn` fields provide market benchmark series useful for checks. Verify source units and missingness before use. If `MthCalDt` appears as `######` in Excel, that may be a display-width issue; the `YYYYMM` field supplies the month key.

## Other required sources

The Table III workflow also requires the locally authorized daily stock source, prepared to the schema documented in `../processed/README.md`. The monthly Fama–French factor CSV must use one of the layouts documented in the repository root README.

## Workflow boundary

The current Stata master workflow consumes processed `.dta` inputs; it does **not** import `monthly_stock.csv` directly. The established Stata analysis remains authoritative. Prepare and check the local processed monthly file against the documented schema before running; do not silently delete duplicate `PERMNO month` observations without inspecting the source rows.

**Do not commit restricted raw CRSP/course data, source archives, or processed licensed data to this public repository.** This file is documentation only.
