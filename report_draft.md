# Momentum Strategies in a Modern U.S. Equity Sample: Replication and Size Heterogeneity

## 1. Research question and motivation

Jegadeesh and Titman (1993) examine whether stocks with strong past returns continue to outperform stocks with weak past returns. A momentum strategy buys past winners and sells past losers. This project applies the paper's market-model approach to a modern sample and asks whether the risk-adjusted winner-minus-loser (WML) return varies across firm-size groups.

## 2. Data and sample

The current analysis uses monthly portfolio returns from December 2001 through December 2025 (289 monthly observations in the supplied analysis files). The full-sample file contains P1–P10 and WML returns plus a market-return series. The size-sorted file contains the same portfolio returns for small, medium, and large firms. The monthly risk-free rate is merged by month from the approved factor file. Licensed course/CRSP source data are not included in this public repository; users must obtain the authorized course packages and reconstruct the documented inputs locally.

This is a modern-sample application of the methodology, not an exact numerical reproduction of the original paper's historical sample. The final report should describe the exact input construction, variable units, screening, and timing after the final data files have been checked.

## 3. Empirical design

For each decile portfolio, estimate the market model:

R(p,t) - RF(t) = alpha(p) + beta(p) [R(m,t) - RF(t)] + error(p,t).

For WML, estimate the same regression using the winner-minus-loser spread as the dependent variable. RF is not subtracted from WML a second time because it is already a long-short return spread. Inference uses Newey–West/HAC standard errors with five lags.

The independent extension formally tests size heterogeneity. For each pair of size groups, regress the difference in their WML return series on the market excess return with an intercept and HAC standard errors. The intercept estimates the difference between the two groups' market-model WML alphas. The extension's CSV results must be generated and checked before drawing conclusions about statistical differences.

## 4. Core replication results

The currently checked Stata results show a positive full-sample WML alpha of 0.011317 per month (approximately 1.132% per month), with a Newey–West t-statistic of 2.94. This is statistically significant at the 1% level using conventional two-sided critical values. The result suggests a positive risk-adjusted momentum spread in this modern sample.

The loser portfolio P1 has an estimated alpha of -0.01035 per month (t = -2.22), significant at the 5% level. The winner portfolio P10 has an alpha of 0.000966 per month (t = 0.44), which is not statistically significant. Thus, in the full-sample estimates, the positive WML result is associated more clearly with the negative alpha of losers than with a statistically significant positive alpha for winners.

The WML estimates across size groups are:

| Sample | Monthly WML alpha | HAC t-statistic | Interpretation |
|---|---:|---:|---|
| Small | 0.014671 (1.467%) | 3.11 | Positive, significant at 1% |
| Medium | 0.010555 (1.056%) | 3.04 | Positive, significant at 1% |
| Large | 0.007460 (0.746%) | 2.65 | Positive, significant at approximately 1% |

The point estimate is largest for small firms and declines across the medium- and large-size groups. This pattern is consistent with stronger momentum among smaller firms, but the ordering of point estimates alone does not establish statistically significant differences. The formal extension tests must be run and reported before making a stronger claim.

## 5. Comparison with the original paper

The qualitative finding of a positive momentum spread is consistent with the broad conclusion of Jegadeesh and Titman (1993). Numerical equality should not be expected because this project uses a modern 2001–2025 sample, rather than the original paper's historical period, and may differ in data coverage and implementation choices. The final report should make these differences explicit and compare only like-for-like strategy definitions where possible.

## 6. Validation and limitations

The project uses monthly portfolio returns and a market-model benchmark, with HAC inference to allow for heteroskedasticity and serial correlation. Before submission, verify month alignment, decimal-versus-percentage units, missingness, market and risk-free-rate merges, and the construction of P10 minus P1. Independently compare the Python outputs with the validated Stata results. The independent extension should be interpreted only after its pairwise tests and generated outputs have been inspected.

## 7. Conclusion

The currently available estimates provide evidence of a positive market-adjusted momentum spread over the modern sample. The spread is positive in all three size groups, with a larger point estimate among small firms. Whether the cross-size differences are statistically distinguishable remains an empirical question to be answered by the extension tests. The final submission should be updated after the documented Python workflow has been run against the approved local inputs and all outputs have been validated.

## References

Jegadeesh, N., & Titman, S. (1993). Returns to Buying Winners and Selling Losers: Implications for Stock Market Efficiency. *The Journal of Finance*, 48(1), 65–91. https://doi.org/10.1111/j.1540-6261.1993.tb04702.x
