# AI-Use Disclosure

This disclosure records the use of AI assistance in preparing the empirical replication workflow. The student remains responsible for all data choices, code, validation, interpretations, and conclusions. Update this file before submission to reflect the work actually completed.

## Where AI was used

- **Project planning:** helped translate the assignment brief into a repository structure and a reproducible workflow.
- **Code development:** assisted with drafting a Python entry point to load local Stata-format analysis files, merge the monthly risk-free rate, estimate market-model regressions with Newey–West/HAC standard errors, and export tables and figures.
- **Extension design:** suggested a size-heterogeneity test based on pairwise differences in size-group WML returns.
- **Documentation:** assisted with drafting the README, data-handling instructions, and a validation checklist.

## How AI-generated work must be checked

Before submission, the student should:
1. Run the script locally with the approved course inputs and inspect every error.
2. Verify month keys, units, missingness, duplicate keys, sample dates, portfolio definitions, and the risk-free-rate merge.
3. Independently confirm that WML is P10 minus P1 and is not reduced by the risk-free rate a second time.
4. Compare regression coefficients, HAC standard errors, t-statistics, sample sizes, and generated figures with independent Stata output or another validated implementation.
5. Check the size-extension hypothesis and the interpretation of each pairwise intercept test.
6. Compare the modern-sample estimates with the original paper and explain sample and implementation differences.
7. Revise the final report so that every reported number comes from checked outputs.

## Important corrections and limitations

During earlier assistance, some Stata guidance required correction, including a svmat syntax issue and time-series metadata problems. These experiences reinforce that AI-generated code should not be accepted without execution and validation.

The repository script is a draft workflow and has **not been verified against the licensed input files in this repository**, because those data are intentionally not published here. Do not claim that the submitted workflow has been successfully reproduced until it has been run and checked locally. Any additional AI use should be documented here accurately.

## Student confirmation

Before final submission, replace or supplement this disclosure with a concise first-person account of the AI tools used, the code/results you personally verified, and any further errors you corrected or rejected.
