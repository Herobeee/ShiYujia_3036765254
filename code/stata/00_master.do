/**********************************************************************
Jegadeesh & Titman (1993) — complete Stata workflow
Run from the repository root in Stata 18:
    do "code/stata/00_master.do"

Primary Table III beta method: daily Scholes–Williams beta.
Tables I and II use the cleaned monthly CRSP stock-level dataset.
Do not commit licensed CRSP/course data to this public repository.
**********************************************************************/
version 18.0
clear all
set more off
set varabbrev off
capture log close _all

capture confirm file "README.md"
if _rc {
    display as error "Set Stata's working directory to the repository root."
    exit 601
}
capture mkdir "outputs"
capture mkdir "outputs/tables"
capture mkdir "outputs/figures"
capture mkdir "outputs/logs"
capture mkdir "data/processed/intermediate"

log using "outputs/logs/JT_full_workflow.log", text replace

foreach f in ///
    "data/processed/crsp_monthly_clean_base.dta" ///
    "data/processed/crsp_daily_common_base_2000_2025.dta" {
    capture confirm file "`f'"
    if _rc {
        display as error "Required local input not found: `f'"
        display as error "Prepare authorized course/CRSP data locally; do not upload restricted data."
        log close
        exit 601
    }
}
capture confirm file "data/raw/F-F_Research_Data_Factors.CSV"
local official_factor_rc = _rc
capture confirm file "data/raw/F-F factors and RF.csv"
local cleaned_factor_rc = _rc
if `official_factor_rc' & `cleaned_factor_rc' {
    display as error "Monthly factor CSV not found in data/raw/."
    log close
    exit 601
}

* 1. Prepare a consistent monthly Mkt-RF/RF factor file.
do "code/stata/01_prepare_monthly_factors.do"

* 2. Tables I and II: monthly stock-level momentum portfolios.
do "code/stata/03_table1.do"
do "code/stata/04_table2.do"

* 3. Table III: size/beta sorts with daily Scholes–Williams beta.
do "code/stata/02_estimate_sw_beta.do"
do "code/stata/03_table3_daily_beta.do"

display as result "All connected Table I–III workflows finished."
display as result "Review outputs/tables and outputs/logs/JT_full_workflow.log."
log close
