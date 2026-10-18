/**********************************************************************
04_table2.do — J=K=6 momentum portfolios

Consumes the J=6, K=6 monthly portfolio series built by 03_table1.do.
Reports mean returns, Newey–West t-statistics, market-model alpha/beta,
and average formation market capitalization. The market factor is the
monthly Fama–French Mkt-RF series; alpha/beta are a modern-sample proxy
specification, not a claim of exact CRSP value-weighted-index replication.
**********************************************************************/
version 18.0
set more off

capture mkdir "outputs"
capture mkdir "outputs/tables"

use "data/processed/intermediate/jt_table1_portfolio_series.dta", clear
keep if J == 6 & K == 6
merge m:1 holding_month using "data/processed/intermediate/jt_factors_monthly.dta", ///
    keep(match) nogen
gen double model_y = portfolio_ret - rf if decile < 11
replace model_y = portfolio_ret if decile == 11
label variable model_y "Excess portfolio return; WML is not adjusted by RF again"

tempname postT2
postfile `postT2' str8 portfolio byte decile ///
    double mean_ret double mean_t double alpha double alpha_t double beta double avg_cap long N ///
    using "outputs/tables/JT_TableII.dta", replace

forvalues d = 1/11 {
    preserve
        keep if decile == `d'
        drop if missing(portfolio_ret, mktrf, rf)
        quietly newey portfolio_ret, lag(5)
        local m = _b[_cons]
        local mt = _b[_cons] / _se[_cons]
        local n = e(N)

        quietly newey model_y mktrf, lag(5)
        local a = _b[_cons]
        local at = _b[_cons] / _se[_cons]
        local b = _b[mktrf]

        quietly summarize avg_cap, meanonly
        local cap = r(mean)

        if `d' == 11 {
            local pname "WML"
        }
        else {
            local pname "P`d'"
        }
        post `postT2' ("`pname'") (`d') (`m') (`mt') (`a') (`at') (`b') (`cap') (`n')
    restore
}
postclose `postT2'

use "outputs/tables/JT_TableII.dta", clear
label variable mean_ret "Mean monthly return (decimal)"
label variable mean_t "Newey-West t-statistic for mean return"
label variable alpha "Market-model alpha (decimal per month)"
label variable alpha_t "Newey-West t-statistic for alpha"
label variable beta "Loading on monthly Mkt-RF"
label variable avg_cap "Average formation market capitalization (source units)"
label variable N "Monthly observations"
format mean_ret alpha avg_cap %12.6f
format mean_t alpha_t beta %9.3f
sort decile
order portfolio decile mean_ret mean_t alpha alpha_t beta avg_cap N
save "outputs/tables/JT_TableII.dta", replace
export delimited using "outputs/tables/JT_TableII.csv", replace
display as result "Table II finished: outputs/tables/JT_TableII.csv"
