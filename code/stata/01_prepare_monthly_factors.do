/**********************************************************************
01_prepare_monthly_factors.do
Creates data/processed/intermediate/jt_factors_monthly.dta.

Supports either:
  data/raw/F-F_Research_Data_Factors.CSV (header row 3; official layout), or
  data/raw/F-F factors and RF.csv (header row 1; cleaned layout).
Expected fields include YYYYMM, Mkt-RF/Mkt_RF/MktRF, and RF.
Source factor values are percentage points and are converted to decimals.
**********************************************************************/
version 18.0
set more off

capture confirm file "data/raw/F-F_Research_Data_Factors.CSV"
if !_rc {
    import delimited using "data/raw/F-F_Research_Data_Factors.CSV", ///
        clear varnames(3) case(lower)
}
else {
    capture confirm file "data/raw/F-F factors and RF.csv"
    if _rc {
        display as error "No monthly factor CSV found."
        display as error "Expected data/raw/F-F_Research_Data_Factors.CSV or data/raw/F-F factors and RF.csv"
        exit 601
    }
    import delimited using "data/raw/F-F factors and RF.csv", ///
        clear varnames(1) case(lower)
}

* Normalize common market-factor header variants.
capture confirm variable mktrf
if _rc {
    capture confirm variable mkt_rf
    if !_rc rename mkt_rf mktrf
}
capture confirm variable rf
if _rc {
    display as error "RF column was not found. Check the factor CSV header."
    exit 111
}
capture confirm variable mktrf
if _rc {
    display as error "Market excess-return column was not found (expected Mkt-RF/Mkt_RF/mktrf)."
    exit 111
}

* The first imported column is the YYYYMM key in both supported layouts.
ds
local allvars `r(varlist)'
local datevar : word 1 of `allvars'
tempvar datekey
capture confirm string variable `datevar'
if !_rc {
    destring `datevar', gen(`datekey') force
}
else {
    gen double `datekey' = `datevar'
}
destring mktrf rf, replace force
keep if inrange(`datekey', 200001, 202512)
gen int holding_month = ym(floor(`datekey'/100), mod(`datekey',100))
format holding_month %tm
replace mktrf = mktrf/100
replace rf = rf/100
keep holding_month mktrf rf
drop if missing(holding_month, mktrf, rf)
isid holding_month
compress
save "data/processed/intermediate/jt_factors_monthly.dta", replace
