/**********************************************************************
01_prepare_monthly_factors.do
Creates data/processed/intermediate/jt_factors_monthly.dta.
Expected French CSV: monthly factors with Mkt_RF and RF on header row 3.
Original factor values are percentage points; convert to decimals here.
**********************************************************************/
version 18.0
import delimited using "data/raw/F-F_Research_Data_Factors.CSV", ///
    clear varnames(3) case(preserve)

ds
local allvars `r(varlist)'
local datevar : word 1 of `allvars'

capture confirm string variable `datevar'
if !_rc {
    destring `datevar', gen(yyyymm) force
}
else {
    gen double yyyymm = `datevar'
}

capture confirm variable Mkt_RF
if _rc {
    display as error "Mkt_RF was not found. Check the French CSV header."
    exit 111
}
capture confirm variable RF
if _rc {
    display as error "RF was not found. Check the French CSV header."
    exit 111
}

keep if inrange(yyyymm, 200001, 202512)
gen int holding_month = ym(floor(yyyymm/100), mod(yyyymm,100))
format holding_month %tm
gen double mktrf = Mkt_RF/100
gen double rf = RF/100
keep holding_month mktrf rf
drop if missing(holding_month, mktrf, rf)
isid holding_month
compress
save "data/processed/intermediate/jt_factors_monthly.dta", replace
