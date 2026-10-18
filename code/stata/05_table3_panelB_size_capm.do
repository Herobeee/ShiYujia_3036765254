/**********************************************************************
05_table3_panelB_size_capm.do

Standalone Table III Panel B for All + size portfolios (Small, Medium,
Large), using the monthly CAPM market model and Newey-West standard
errors. This preserves the user's working calculation while replacing
machine-specific absolute paths with repository-relative paths.

Run from the repository root in Stata 18:
    do "code/stata/05_table3_panelB_size_capm.do"

Required local inputs (not committed):
    data/processed/intermediate/JT_TableII_returns_with_market.dta
        holding_month, mkt_return, portret1-portret10, WML
    data/processed/intermediate/JT_TableIII_size_panelA_monthly.dta
        holding_month, sizegrp (1=Small, 2=Medium, 3=Large),
        portret1-portret10, WML
    data/processed/intermediate/FF_monthly_factors.dta
        holding_month, rf_decimal

Outputs:
    outputs/tables/JT_TableIII_PanelB_size_only.dta
    outputs/tables/JT_TableIII_PanelB_size_only.csv

This standalone script is not called by 00_master.do. The integrated
Table III workflow is code/stata/03_table3_daily_beta.do. Results have
not been independently validated in this environment.
**********************************************************************/

version 18.0
clear all
set more off

* 1. Paths: run this do-file from the repository root.
local root "."
local file_all  "`root'/data/processed/intermediate/JT_TableII_returns_with_market.dta"
local file_size "`root'/data/processed/intermediate/JT_TableIII_size_panelA_monthly.dta"
local file_ff   "`root'/data/processed/intermediate/FF_monthly_factors.dta"
local outdir    "`root'/outputs/tables"

* Fail early with a useful message if a local input is missing.
capture confirm file "`file_all'"
if _rc {
    display as error "Missing input: `file_all'"
    display as error "Place the locally generated Table II monthly portfolio series at this path."
    exit 601
}
capture confirm file "`file_size'"
if _rc {
    display as error "Missing input: `file_size'"
    display as error "Place the locally generated monthly size-portfolio series at this path."
    exit 601
}
capture confirm file "`file_ff'"
if _rc {
    display as error "Missing input: `file_ff'"
    display as error "Create the monthly factor DTA with holding_month and rf_decimal."
    exit 601
}

* 2. Prepare the risk-free rate series.
use "`file_ff'", clear
keep holding_month rf_decimal
isid holding_month
tempfile ff
save `ff', replace

* 3. Prepare the All-sample monthly portfolio returns.
use "`file_all'", clear
capture drop rf_decimal
merge 1:1 holding_month using `ff', keep(match) nogen
gen byte sizegrp = 0
tempfile all_ready
save `all_ready', replace

* 4. Prepare a unique monthly market-return series.
use "`file_all'", clear
keep holding_month mkt_return
isid holding_month
tempfile market
save `market', replace

* 5. Prepare size-sorted monthly portfolios.
use "`file_size'", clear
capture drop mkt_return
capture drop rf_decimal
merge m:1 holding_month using `ff', keep(match) nogen
merge m:1 holding_month using `market', keep(match) nogen
assert !missing(rf_decimal)
assert !missing(mkt_return)
isid holding_month sizegrp
tempfile size_ready
save `size_ready', replace

* 6. Store 4 samples x 11 portfolios (P1-P10 and WML).
* Columns: sizegrp, portfolio number, alpha, NW t-statistic, N, WML flag.
matrix RESULTS = J(44, 6, .)
local row = 0

* 7. Estimate the CAPM for All, Small, Medium and Large portfolios.
forvalues s = 0/3 {
    if `s' == 0 {
        use `all_ready', clear
    }
    else {
        use `size_ready', clear
        keep if sizegrp == `s'
    }

    local sam "All"
    if `s' == 1 local sam "Small"
    if `s' == 2 local sam "Medium"
    if `s' == 3 local sam "Large"

    isid holding_month
    tsset holding_month
    gen double mkt_excess = mkt_return - rf_decimal

    * P1-P10: regress portfolio excess return on market excess return.
    forvalues p = 1/10 {
        local row = `row' + 1
        tempvar exret
        gen double `exret' = portret`p' - rf_decimal
        quietly newey `exret' mkt_excess, lag(5)

        matrix RESULTS[`row',1] = `s'
        matrix RESULTS[`row',2] = `p'
        matrix RESULTS[`row',3] = _b[_cons]
        matrix RESULTS[`row',4] = _b[_cons] / _se[_cons]
        matrix RESULTS[`row',5] = e(N)
        matrix RESULTS[`row',6] = 0
        drop `exret'
    }

    * WML = winner portfolio minus loser portfolio.
    local row = `row' + 1
    quietly newey WML mkt_excess, lag(5)
    matrix RESULTS[`row',1] = `s'
    matrix RESULTS[`row',2] = 11
    matrix RESULTS[`row',3] = _b[_cons]
    matrix RESULTS[`row',4] = _b[_cons] / _se[_cons]
    matrix RESULTS[`row',5] = e(N)
    matrix RESULTS[`row',6] = 1
}

* 8. Convert the results matrix to a dataset.
clear
svmat double RESULTS, names
rename RESULTS1 sizegrp
rename RESULTS2 portfolio_num
rename RESULTS3 alpha
rename RESULTS4 nw_t
rename RESULTS5 N
rename RESULTS6 is_WML

* 9. Portfolio and sample labels.
gen str8 portfolio = "P" + strtrim(string(portfolio_num, "%2.0f"))
replace portfolio = "WML" if is_WML == 1

gen str8 sample = "All"
replace sample = "Small"  if sizegrp == 1
replace sample = "Medium" if sizegrp == 2
replace sample = "Large"  if sizegrp == 3

* 10. Format, inspect and export.
order sample sizegrp portfolio alpha nw_t N portfolio_num is_WML
format alpha %9.5f
format nw_t %9.3f
sort sizegrp portfolio_num

list sample portfolio alpha nw_t N, sepby(sample)

save "`outdir'/JT_TableIII_PanelB_size_only.dta", replace
export delimited using "`outdir'/JT_TableIII_PanelB_size_only.csv", replace

display as result "Table III Panel B (size-only) outputs saved."
