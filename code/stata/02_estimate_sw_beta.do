/**********************************************************************
02_estimate_sw_beta.do
Primary beta construction for Table III beta-sorted portfolios.

1. Build a daily value-weighted market-return proxy using lagged market cap.
2. Estimate its first-order autocorrelation rho.
3. Estimate annual regressions by PERMNO:
     stock return = b_lag*mkt_lag + b0*mkt + b_lead*mkt_lead + error
4. beta_SW = (b_lag + b0 + b_lead)/(1 + 2*rho).

At least 100 complete daily observations are required per PERMNO-year.
A formation month in year Y uses the beta estimated in year Y-1.
Caveat: the proxy is built from supplied ordinary stocks and is not
guaranteed to equal the original CRSP value-weighted index.
**********************************************************************/
version 18.0
use "data/processed/crsp_daily_common_base_2000_2025.dta", clear
keep if inrange(year(date), 2000, 2025)
keep date PERMNO DlyRet DlyPrevCap
drop if missing(date, PERMNO, DlyRet, DlyPrevCap)
keep if DlyPrevCap > 0
assert DlyRet >= -1 if !missing(DlyRet)

gen double weighted_ret = DlyPrevCap * DlyRet
collapse (sum) weighted_ret DlyPrevCap, by(date)
rename DlyPrevCap total_prev_cap
gen double mkt_ret = weighted_ret / total_prev_cap
keep date mkt_ret
sort date
isid date

* Lead/lag are adjacent observed trading days, not calendar days.
gen long trade_day = _n
tsset trade_day
gen double mkt_lag = L.mkt_ret
gen double mkt_lead = F.mkt_ret
gen int year = year(date)
format date %td
save "data/processed/intermediate/jt_market_daily_proxy.dta", replace

quietly correlate mkt_ret mkt_lag
matrix C = r(C)
scalar rho_m = C[1,2]
if missing(rho_m) | abs(1 + 2*rho_m) < 1e-8 {
    display as error "Invalid Scholes-Williams correction denominator."
    exit 459
}
display as text "Market proxy autocorrelation rho = " as result %8.5f rho_m

use "data/processed/crsp_daily_common_base_2000_2025.dta", clear
keep if inrange(year(date), 2000, 2025)
merge m:1 date using "data/processed/intermediate/jt_market_daily_proxy.dta", ///
    keepusing(mkt_ret mkt_lag mkt_lead) keep(match) nogen

gen int year = year(date)
gen byte regsample = !missing(DlyRet, mkt_lag, mkt_ret, mkt_lead)
bysort PERMNO year: egen long nreg = total(regsample)
keep if nreg >= 100 & regsample

statsby ///
    b_lag = _b[mkt_lag] ///
    b0 = _b[mkt_ret] ///
    b_lead = _b[mkt_lead] ///
    N = e(N), by(PERMNO year) ///
    saving("data/processed/intermediate/jt_sw_beta_coefficients.dta", replace): ///
    regress DlyRet mkt_lag mkt_ret mkt_lead

use "data/processed/intermediate/jt_sw_beta_coefficients.dta", clear
gen double beta_SW = (b_lag + b0 + b_lead) / (1 + 2*rho_m)
rename year beta_year
label variable beta_SW "Scholes-Williams beta"
label variable beta_year "Calendar year used to estimate beta"
format beta_SW %9.4f
isid PERMNO beta_year
compress
save "data/processed/intermediate/jt_sw_beta_by_stock_year.dta", replace
