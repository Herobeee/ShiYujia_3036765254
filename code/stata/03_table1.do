/**********************************************************************
03_table1.do — Jegadeesh–Titman monthly momentum strategies

Input: data/processed/crsp_monthly_clean_base.dta
Expected fields: PERMNO month MthRet MthCap SecuritySubType
No xtset/panel declaration is required; calendar-month lags are created
by merging shifted monthly keys. Requires Stata 18.
Returns are decimals. Table I uses equal-weighted deciles, overlapping
holding cohorts, and Newey–West lag K-1 for each K-month strategy.
**********************************************************************/
version 18.0
set more off

capture mkdir "data/processed/intermediate"
capture mkdir "outputs"
capture mkdir "outputs/tables"

use "data/processed/crsp_monthly_clean_base.dta", clear
keep if inrange(month, ym(2000,1), ym(2025,12))
keep if SecuritySubType == "COM"
keep PERMNO month MthRet MthCap
drop if missing(PERMNO, month)
isid PERMNO month
format month %tm
tempfile raw work hold lagfile cohortall seriesall
save `raw', replace
save `work', replace

* Create exact calendar-month lags by shifting the source month key.
forvalues ell = 1/12 {
    use `raw', clear
    keep PERMNO month MthRet
    replace month = month + `ell'
    rename MthRet lagret`ell'
    isid PERMNO month
    save `lagfile', replace

    use `work', clear
    merge 1:1 PERMNO month using `lagfile', keep(master match) nogen
    save `work', replace
}

* Holding-period returns are drawn from the same cleaned stock universe.
use `raw', clear
keep PERMNO month MthRet
rename month holding_month
rename MthRet hold_ret
drop if missing(hold_ret)
isid PERMNO holding_month
save `hold', replace

local jlist "3 6 9 12"
* Form the winner/loser deciles once for each formation lookback J.
foreach J of local jlist {
    use `work', clear
    gen double formret`J' = 1
    gen byte nlag`J' = 0
    forvalues ell = 1/`J' {
        replace formret`J' = formret`J' * (1 + lagret`ell') if !missing(lagret`ell')
        replace nlag`J' = nlag`J' + 1 if !missing(lagret`ell')
    }
    replace formret`J' = . if nlag`J' != `J'

    * Project-specific robustness treatment: winsorize J=6 formation returns
    * cross-sectionally within each formation month at the 1st/99th percentiles.
    * This is an added implementation choice, not a step attributed to JT (1993).
    if `J' == 6 {
        levelsof month if !missing(formret`J'), local(wmonths)
        foreach mm of local wmonths {
            quietly _pctile formret`J' if month == `mm' & !missing(formret`J'), p(1 99)
            local p1 = r(r1)
            local p99 = r(r2)
            replace formret`J' = `p1' if month == `mm' & formret`J' < `p1' & !missing(formret`J')
            replace formret`J' = `p99' if month == `mm' & formret`J' > `p99' & !missing(formret`J')
        }
    }

    gen byte rank`J' = .
    levelsof month if !missing(formret`J'), local(forms)
    foreach mm of local forms {
        capture drop __rank
        quietly xtile __rank = formret`J' if month == `mm' & !missing(formret`J'), nq(10)
        replace rank`J' = __rank if month == `mm' & !missing(formret`J')
        drop __rank
    }

    keep PERMNO month MthCap rank`J'
    rename MthCap formation_cap
    save "data/processed/intermediate/jt_table1_rank_J`J'.dta", replace
}

* Build all J x K overlapping portfolio return series.
local series_init = 1
foreach J of local jlist {
    forvalues K = 3(3)12 {
        local first_cohort = 1
        local last_h = `K' - 1

        forvalues h = 0/`last_h' {
            use "data/processed/intermediate/jt_table1_rank_J`J'.dta", clear
            keep if !missing(rank`J')
            rename month formation_month
            gen int holding_month = formation_month + `h'
            merge m:1 PERMNO holding_month using `hold', keep(match) nogen

            collapse (mean) cohort_ret=hold_ret cohort_cap=formation_cap, ///
                by(formation_month holding_month rank`J')
            rename rank`J' decile

            if `first_cohort' {
                save `cohortall', replace
                local first_cohort = 0
            }
            else {
                append using `cohortall'
                save `cohortall', replace
            }
        }

        use `cohortall', clear
        * Equal-weight active formation cohorts within each calendar month.
        collapse (mean) portfolio_ret=cohort_ret avg_cap=cohort_cap, ///
            by(holding_month decile)
        gen byte J = `J'
        gen byte K = `K'
        keep if inrange(holding_month, ym(2001,12), ym(2025,12))

        reshape wide portfolio_ret avg_cap, i(holding_month J K) j(decile)
        capture confirm variable portfolio_ret10
        if _rc {
            display as error "Could not form all ten deciles for J=`J', K=`K'."
            exit 459
        }
        gen double portfolio_ret11 = portfolio_ret10 - portfolio_ret1
        gen double avg_cap11 = .
        reshape long portfolio_ret avg_cap, i(holding_month J K) j(decile)
        sort holding_month decile
        compress

        if `series_init' {
            save `seriesall', replace
            local series_init = 0
        }
        else {
            append using `seriesall'
            save `seriesall', replace
        }
    }
}

use `seriesall', clear
label variable portfolio_ret "Monthly portfolio return (decimal)"
label variable avg_cap "Mean formation market capitalization (source units)"
save "data/processed/intermediate/jt_table1_portfolio_series.dta", replace

tempname postT1
postfile `postT1' byte J byte K str8 portfolio byte decile ///
    double mean_ret double t_stat long N ///
    using "outputs/tables/JT_TableI.dta", replace

foreach J of local jlist {
    foreach K of local jlist {
        local nwlag = `K' - 1
        forvalues d = 1/11 {
            use `seriesall', clear
            keep if J == `J' & K == `K' & decile == `d'
            drop if missing(portfolio_ret)
            quietly newey portfolio_ret, lag(`nwlag')
            local m = _b[_cons]
            local t = _b[_cons] / _se[_cons]
            local n = e(N)
            if `d' == 11 {
                local pname "WML"
            }
            else {
                local pname "P`d'"
            }
            post `postT1' (`J') (`K') ("`pname'") (`d') (`m') (`t') (`n')
        }
    }
}
postclose `postT1'

use "outputs/tables/JT_TableI.dta", clear
label variable J "Formation lookback J (months)"
label variable K "Holding period K (months)"
label variable mean_ret "Mean monthly return (decimal)"
label variable t_stat "Newey-West t-statistic"
label variable N "Monthly observations"
format mean_ret %9.5f
format t_stat %8.3f
sort J K decile
order J K portfolio decile mean_ret t_stat N
save "outputs/tables/JT_TableI.dta", replace
export delimited using "outputs/tables/JT_TableI.csv", replace
display as result "Table I finished: outputs/tables/JT_TableI.csv"
