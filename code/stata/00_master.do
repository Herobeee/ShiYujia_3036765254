/**********************************************************************
Jegadeesh & Titman (1993) — master workflow
PRIMARY Table III route: daily Scholes-Williams beta.
Run from repository root in Stata 18:
    do "code/stata/00_master.do"

Required local inputs (never commit restricted CRSP data):
  data/processed/crsp_monthly_clean_base.dta
  data/processed/crsp_daily_common_base_2000_2025.dta
  data/raw/F-F_Research_Data_Factors.CSV

Monthly rolling-beta prototype is not called here. Table I/II modules are
kept separate until their final sample/variable definitions are confirmed.
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

log using "outputs/logs/JT_daily_beta_workflow.log", text replace
foreach f in ///
    "data/processed/crsp_monthly_clean_base.dta" ///
    "data/processed/crsp_daily_common_base_2000_2025.dta" ///
    "data/raw/F-F_Research_Data_Factors.CSV" {
    capture confirm file "`f'"
    if _rc {
        display as error "Required input not found: `f'"
        display as error "Keep licensed input data local; do not upload it to GitHub."
        log close
        exit 601
    }
}

do "code/stata/01_prepare_monthly_factors.do"
do "code/stata/02_estimate_sw_beta.do"
do "code/stata/03_table3_daily_beta.do"

display as result "Daily-beta Table III workflow finished. Review outputs and log."
log close
