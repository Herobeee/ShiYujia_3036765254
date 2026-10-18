/**********************************************************************
03_table3_daily_beta.do

Table III-style output using prior-year daily Scholes-Williams beta groups.
Outputs are unverified until run locally in Stata with licensed data.
**********************************************************************/
version 18.0

* 1. Formation-month characteristics, using explicit calendar-month merges.
* This avoids xtset and ensures that lag means the prior calendar month.
use "data/processed/crsp_monthly_clean_base.dta", clear
keep if inrange(month, ym(2000,1), ym(2025,12))
keep if SecuritySubType == "COM"
keep PERMNO month MthRet MthCap
isid PERMNO month
format month %tm
tempfile monthly_base monthly_work lagfile
save `monthly_base', replace
save `monthly_work', replace

forvalues ell = 1/6 {
    use `monthly_base', clear
    keep PERMNO month MthRet
    replace month = month + `ell'
    rename MthRet lagret`ell'
    isid PERMNO month
    save `lagfile', replace

    use `monthly_work', clear
    merge 1:1 PERMNO month using `lagfile', keep(master match) nogen
    save `monthly_work', replace
}

tempfile caplag
use `monthly_base', clear
keep PERMNO month MthCap
replace month = month + 1
rename MthCap formation_cap
isid PERMNO month
save `caplag', replace
use `monthly_work', clear
merge 1:1 PERMNO month using `caplag', keep(master match) nogen

gen double formret6 = 1
gen byte nlag6 = 0
forvalues ell = 1/6 {
    replace formret6 = formret6 * (1 + lagret`ell') if !missing(lagret`ell')
    replace nlag6 = nlag6 + 1 if !missing(lagret`ell')
}
replace formret6 = . if nlag6 != 6

* Project-specific robustness treatment: winsorize six-month formation returns
* cross-sectionally within formation month at the 1st/99th percentiles.
* This is an added implementation choice, not a step attributed to JT (1993).
levelsof month if !missing(formret6), local(wmonths)
foreach mm of local wmonths {
    quietly _pctile formret6 if month == `mm' & !missing(formret6), p(1 99)
    local p1 = r(r1)
    local p99 = r(r2)
    replace formret6 = `p1' if month == `mm' & formret6 < `p1' & !missing(formret6)
    replace formret6 = `p99' if month == `mm' & formret6 > `p99' & !missing(formret6)
}

gen int beta_year = year(dofm(month)) - 1
merge m:1 PERMNO beta_year using ///
    "data/processed/intermediate/jt_sw_beta_by_stock_year.dta", ///
    keepusing(beta_SW) keep(master match) nogen

* Monthly size terciles and beta terciles.
gen byte size_group = .
gen byte beta_group = .
levelsof month if formation_cap > 0 & !missing(formation_cap), local(sizemonths)
foreach mm of local sizemonths {
    capture drop __grp
    quietly xtile __grp = formation_cap if month == `mm' & formation_cap > 0 & !missing(formation_cap), nq(3)
    replace size_group = __grp if month == `mm' & formation_cap > 0 & !missing(formation_cap)
    drop __grp
}
levelsof month if !missing(beta_SW), local(betmonths)
foreach mm of local betmonths {
    capture drop __grp
    quietly xtile __grp = beta_SW if month == `mm' & !missing(beta_SW), nq(3)
    replace beta_group = __grp if month == `mm' & !missing(beta_SW)
    drop __grp
}

* Momentum deciles: full universe, within size terciles, within beta terciles.
gen byte rank_all = .
levelsof month if !missing(formret6), local(allmonths)
foreach mm of local allmonths {
    capture drop __rank
    quietly xtile __rank = formret6 if month == `mm' & !missing(formret6), nq(10)
    replace rank_all = __rank if month == `mm' & !missing(formret6)
    drop __rank
}
forvalues g = 1/3 {
    gen byte rank_size`g' = .
    gen byte rank_beta`g' = .
    levelsof month if !missing(formret6) & size_group == `g', local(sm)
    foreach mm of local sm {
        capture drop __rank
        quietly xtile __rank = formret6 if month == `mm' & size_group == `g' & !missing(formret6), nq(10)
        replace rank_size`g' = __rank if month == `mm' & size_group == `g' & !missing(formret6)
        drop __rank
    }
    levelsof month if !missing(formret6) & beta_group == `g', local(bm)
    foreach mm of local bm {
        capture drop __rank
        quietly xtile __rank = formret6 if month == `mm' & beta_group == `g' & !missing(formret6), nq(10)
        replace rank_beta`g' = __rank if month == `mm' & beta_group == `g' & !missing(formret6)
        drop __rank
    }
}

keep PERMNO month formation_cap rank_all rank_size1 rank_size2 rank_size3 ///
    rank_beta1 rank_beta2 rank_beta3
compress
save "data/processed/intermediate/jt_table3_ranked_stocks.dta", replace

* 2. Monthly stock returns available in the holding period.
preserve
    use "data/processed/crsp_monthly_clean_base.dta", clear
    keep if inrange(month, ym(2000,1), ym(2025,12))
    keep if SecuritySubType == "COM"
    keep PERMNO month MthRet
    drop if missing(MthRet)
    rename month holding_month
    rename MthRet hold_ret
    isid PERMNO holding_month
    format holding_month %tm
    save "data/processed/intermediate/jt_stock_returns.dta", replace
restore

* 3. Expand each formation month into holding months t,...,t+5.
tempfile cohorts
local first = 1
forvalues h = 0/5 {
    use "data/processed/intermediate/jt_table3_ranked_stocks.dta", clear
    rename month formation_month
    gen int holding_month = formation_month + `h'
    gen byte hold_h = `h'
    merge m:1 PERMNO holding_month using ///
        "data/processed/intermediate/jt_stock_returns.dta", keep(match) nogen
    keep PERMNO formation_month holding_month hold_h hold_ret formation_cap ///
        rank_all rank_size1 rank_size2 rank_size3 rank_beta1 rank_beta2 rank_beta3
    if `first' {
        save `cohorts', replace
        local first = 0
    }
    else {
        append using `cohorts'
        save `cohorts', replace
    }
}
use `cohorts', clear
save "data/processed/intermediate/jt_table3_cohorts.dta", replace

* 4. Estimate raw returns and CAPM alphas for each sample/group.
tempname postA postB
postfile `postA' str16 sample byte decile double mean_ret t_stat long N ///
    using "outputs/tables/JT_TableIII_PanelA_daily_beta.dta", replace
postfile `postB' str16 sample byte decile double alpha t_stat long N ///
    using "outputs/tables/JT_TableIII_PanelB_daily_beta.dta", replace

local rankvars "rank_all rank_size1 rank_size2 rank_size3 rank_beta1 rank_beta2 rank_beta3"
local labels "All SizeSmall SizeMedium SizeLarge BetaLow BetaMedium BetaHigh"
local idx = 0
foreach rv of local rankvars {
    local ++idx
    local lab : word `idx' of `labels'
    use "data/processed/intermediate/jt_table3_cohorts.dta", clear
    keep if hold_h < 6 & !missing(`rv')
    rename `rv' decile
    collapse (mean) cohort_ret=hold_ret, by(formation_month holding_month decile)
    collapse (mean) portfolio_ret=cohort_ret, by(holding_month decile)
    keep if inrange(holding_month, ym(2001,12), ym(2025,12))
    tempfile series
    save `series', replace

    * Panel A: raw portfolio returns and WML, NW(5).
    forvalues d = 1/10 {
        use `series', clear
        keep if decile == `d'
        tsset holding_month
        quietly newey portfolio_ret, lag(5)
        post `postA' ("`lab'") (`d') (_b[_cons]) (_b[_cons]/_se[_cons]) (e(N))
    }
    use `series', clear
    keep if inlist(decile,1,10)
    keep holding_month decile portfolio_ret
    reshape wide portfolio_ret, i(holding_month) j(decile)
    gen double wml = portfolio_ret10 - portfolio_ret1
    tsset holding_month
    quietly newey wml, lag(5)
    post `postA' ("`lab'") (11) (_b[_cons]) (_b[_cons]/_se[_cons]) (e(N))

    * Add factor returns for CAPM alphas.
    use `series', clear
    merge m:1 holding_month using "data/processed/intermediate/jt_factors_monthly.dta", ///
        keep(match) nogen
    save `series', replace

    forvalues d = 1/10 {
        use `series', clear
        keep if decile == `d'
        gen double excess_ret = portfolio_ret - rf
        tsset holding_month
        quietly newey excess_ret mktrf, lag(5)
        post `postB' ("`lab'") (`d') (_b[_cons]) (_b[_cons]/_se[_cons]) (e(N))
    }
    use `series', clear
    keep if inlist(decile,1,10)
    keep holding_month decile portfolio_ret mktrf
    reshape wide portfolio_ret, i(holding_month) j(decile)
    gen double wml = portfolio_ret10 - portfolio_ret1
    tsset holding_month
    quietly newey wml mktrf, lag(5)
    post `postB' ("`lab'") (11) (_b[_cons]) (_b[_cons]/_se[_cons]) (e(N))
}
postclose `postA'
postclose `postB'

* 5. Label and export outputs.
use "outputs/tables/JT_TableIII_PanelA_daily_beta.dta", clear
gen str8 portfolio = cond(decile==11,"P10-P1","P"+string(decile,"%1.0f"))
gen byte sample_order = .
replace sample_order = 1 if sample=="All"
replace sample_order = 2 if sample=="SizeSmall"
replace sample_order = 3 if sample=="SizeMedium"
replace sample_order = 4 if sample=="SizeLarge"
replace sample_order = 5 if sample=="BetaLow"
replace sample_order = 6 if sample=="BetaMedium"
replace sample_order = 7 if sample=="BetaHigh"
format mean_ret %9.5f
format t_stat %8.3f
sort sample_order decile
order sample sample_order portfolio decile mean_ret t_stat N
save "outputs/tables/JT_TableIII_PanelA_daily_beta.dta", replace
export delimited using "outputs/tables/JT_TableIII_PanelA_daily_beta.csv", replace

use "outputs/tables/JT_TableIII_PanelB_daily_beta.dta", clear
gen str8 portfolio = cond(decile==11,"P10-P1","P"+string(decile,"%1.0f"))
gen byte sample_order = .
replace sample_order = 1 if sample=="All"
replace sample_order = 2 if sample=="SizeSmall"
replace sample_order = 3 if sample=="SizeMedium"
replace sample_order = 4 if sample=="SizeLarge"
replace sample_order = 5 if sample=="BetaLow"
replace sample_order = 6 if sample=="BetaMedium"
replace sample_order = 7 if sample=="BetaHigh"
format alpha %9.5f
format t_stat %8.3f
sort sample_order decile
order sample sample_order portfolio decile alpha t_stat N
save "outputs/tables/JT_TableIII_PanelB_daily_beta.dta", replace
export delimited using "outputs/tables/JT_TableIII_PanelB_daily_beta.csv", replace

* Preserve the All-sample monthly portfolio-return series for audit.
use "data/processed/intermediate/jt_table3_cohorts.dta", clear
keep if hold_h < 6 & !missing(rank_all)
rename rank_all decile
collapse (mean) cohort_ret=hold_ret, by(formation_month holding_month decile)
collapse (mean) portfolio_ret=cohort_ret, by(holding_month decile)
keep if inrange(holding_month, ym(2001,12), ym(2025,12))
save "outputs/tables/JT_TableIII_daily_beta_portfolio_returns.dta", replace
