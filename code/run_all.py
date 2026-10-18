#!/usr/bin/env python3
"""Reproduce the modern-sample momentum market-model results.

Run from any working directory:
    python code/run_all.py

Restricted input data are intentionally not bundled with this repository.
Returns and factor values are expected to be decimals, not percentage points.
"""
from __future__ import annotations

import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.api as sm

ROOT = Path(__file__).resolve().parents[1]
INPUT_DIR = ROOT / "data" / "processed"
TABLE_DIR = ROOT / "outputs" / "tables"
FIGURE_DIR = ROOT / "outputs" / "figures"
START_MONTH = (2001, 12)
END_MONTH = (2025, 12)
HAC_LAGS = 5
PORTFOLIOS = [f"portret{i}" for i in range(1, 11)]
REQUIRED_FILES = {
    "all": INPUT_DIR / "JT_TableII_returns_with_market.dta",
    "size": INPUT_DIR / "JT_TableIII_size_panelA_monthly.dta",
    "factors": INPUT_DIR / "FF_monthly_factors.dta",
}


def read_stata(path: Path) -> pd.DataFrame:
    """Read Stata data without converting %tm dates into Python date objects."""
    if not path.exists():
        raise FileNotFoundError(
            f"Required input not found: {path.relative_to(ROOT)}\n"
            "Obtain the approved course data, process it locally, and place the "
            "file at this path. Do not upload restricted course/CRSP data to GitHub."
        )
    return pd.read_stata(path, convert_dates=False)


def require_columns(df: pd.DataFrame, columns: list[str], label: str) -> None:
    missing = [col for col in columns if col not in df.columns]
    if missing:
        raise ValueError(f"{label} is missing required column(s): {', '.join(missing)}")


def numeric_months(df: pd.DataFrame, label: str) -> pd.DataFrame:
    require_columns(df, ["holding_month"], label)
    out = df.copy()
    out["holding_month"] = pd.to_numeric(out["holding_month"], errors="coerce")
    if out["holding_month"].isna().any():
        raise ValueError(f"{label}: holding_month contains non-numeric or missing values.")
    out["holding_month"] = out["holding_month"].astype("int64")
    return out


def hac_regression(y: pd.Series, x: pd.Series) -> dict[str, float | int]:
    """OLS with an intercept and Newey-West/HAC covariance."""
    frame = pd.concat([pd.to_numeric(y, errors="coerce"), pd.to_numeric(x, errors="coerce")], axis=1)
    frame.columns = ["y", "x"]
    frame = frame.replace([np.inf, -np.inf], np.nan).dropna()
    if len(frame) <= HAC_LAGS + 2:
        raise ValueError(f"Only {len(frame)} complete observations; too few for HAC lag {HAC_LAGS}.")
    fit = sm.OLS(frame["y"], sm.add_constant(frame["x"])).fit(
        cov_type="HAC", cov_kwds={"maxlags": HAC_LAGS}
    )
    return {
        "alpha": float(fit.params["const"]),
        "beta": float(fit.params["x"]),
        "nw_t": float(fit.tvalues["const"]),
        "nw_se": float(fit.bse["const"]),
        "N": int(fit.nobs),
        "r_squared": float(fit.rsquared),
    }


def prepare_inputs() -> tuple[pd.DataFrame, pd.DataFrame]:
    all_df = numeric_months(read_stata(REQUIRED_FILES["all"]), "full-sample returns")
    size_df = numeric_months(read_stata(REQUIRED_FILES["size"]), "size-group returns")
    factors = numeric_months(read_stata(REQUIRED_FILES["factors"]), "factor file")

    require_columns(all_df, ["mkt_return", "WML", *PORTFOLIOS], "full-sample returns")
    require_columns(size_df, ["sizegrp", "WML", *PORTFOLIOS], "size-group returns")
    require_columns(factors, ["rf_decimal"], "factor file")

    if all_df["holding_month"].duplicated().any():
        raise ValueError("Full-sample returns must have one row per holding_month.")
    if factors["holding_month"].duplicated().any():
        raise ValueError("Factor file must have one row per holding_month.")
    if size_df.duplicated(["holding_month", "sizegrp"]).any():
        raise ValueError("Size-group data must have one row per holding_month and sizegrp.")

    # Preserve the market-return series supplied with the full-sample portfolio file.
    market = all_df[["holding_month", "mkt_return"]].copy()
    market["mkt_return"] = pd.to_numeric(market["mkt_return"], errors="coerce")
    rf = factors[["holding_month", "rf_decimal"]].copy()
    rf["rf_decimal"] = pd.to_numeric(rf["rf_decimal"], errors="coerce")

    all_df = all_df.merge(rf, on="holding_month", how="left", validate="one_to_one")
    size_df = size_df.drop(columns=["mkt_return"], errors="ignore")
    size_df = size_df.merge(market, on="holding_month", how="left", validate="many_to_one")
    size_df = size_df.merge(rf, on="holding_month", how="left", validate="many_to_one")

    # Stata monthly dates are integers counted from 1960m1. Restrict to the
    # documented modern sample while preserving the original month key.
    start_key = (START_MONTH[0] - 1960) * 12 + START_MONTH[1] - 1
    end_key = (END_MONTH[0] - 1960) * 12 + END_MONTH[1] - 1
    all_df = all_df.loc[all_df["holding_month"].between(start_key, end_key)].copy()
    size_df = size_df.loc[size_df["holding_month"].between(start_key, end_key)].copy()

    for label, frame in [("full-sample returns", all_df), ("size-group returns", size_df)]:
        if frame["rf_decimal"].isna().any():
            n_missing = int(frame["rf_decimal"].isna().sum())
            raise ValueError(f"{label}: risk-free rate missing for {n_missing} row(s) after month merge.")
        if frame["mkt_return"].isna().any():
            n_missing = int(frame["mkt_return"].isna().sum())
            raise ValueError(f"{label}: market return missing for {n_missing} row(s) after month merge.")

    return all_df.sort_values("holding_month"), size_df.sort_values(["sizegrp", "holding_month"])


def run_core(all_df: pd.DataFrame, size_df: pd.DataFrame) -> pd.DataFrame:
    records: list[dict[str, object]] = []
    samples: list[tuple[str, pd.DataFrame, int | None]] = [("All", all_df, None)]
    for group_code, group_name in [(1, "Small"), (2, "Medium"), (3, "Large")]:
        group = size_df.loc[size_df["sizegrp"] == group_code].copy()
        if group.empty:
            raise ValueError(f"No observations found for sizegrp={group_code} ({group_name}).")
        samples.append((group_name, group, group_code))

    for sample_name, frame, group_code in samples:
        market_excess = frame["mkt_return"] - frame["rf_decimal"]
        for portfolio in PORTFOLIOS:
            y = pd.to_numeric(frame[portfolio], errors="coerce") - frame["rf_decimal"]
            result = hac_regression(y, market_excess)
            records.append({
                "sample": sample_name, "sizegrp": group_code,
                "portfolio": f"P{portfolio.removeprefix('portret')}",
                **result, "return_definition": "portfolio return minus RF",
            })
        # WML is a long-short spread; do not subtract RF again.
        result = hac_regression(frame["WML"], market_excess)
        records.append({
            "sample": sample_name, "sizegrp": group_code,
            "portfolio": "WML", **result,
            "return_definition": "winner return minus loser return",
        })

    results = pd.DataFrame(records)
    results["alpha_pct_per_month"] = 100 * results["alpha"]
    results["nw_se_pct_per_month"] = 100 * results["nw_se"]
    results.to_csv(TABLE_DIR / "core_replication_alphas.csv", index=False)
    return results


def run_size_extension(size_df: pd.DataFrame) -> pd.DataFrame:
    """Test pairwise equality of size-group WML alphas using return differences."""
    wide = size_df.pivot(index="holding_month", columns="sizegrp", values="WML")
    wide.columns = [f"WML_size{int(col)}" for col in wide.columns]
    market = size_df[["holding_month", "mkt_return", "rf_decimal"]].drop_duplicates("holding_month")
    panel = wide.reset_index().merge(market, on="holding_month", how="inner", validate="one_to_one")
    panel["mkt_excess"] = panel["mkt_return"] - panel["rf_decimal"]

    comparisons = [
        (1, 2, "Small - Medium"),
        (1, 3, "Small - Large"),
        (2, 3, "Medium - Large"),
    ]
    rows: list[dict[str, object]] = []
    for a, b, label in comparisons:
        left, right = f"WML_size{a}", f"WML_size{b}"
        if left not in panel or right not in panel:
            raise ValueError("The size extension requires sizegrp values 1, 2, and 3.")
        result = hac_regression(panel[left] - panel[right], panel["mkt_excess"])
        rows.append({
            "comparison": label,
            "alpha_difference": result["alpha"],
            "alpha_difference_pct_per_month": 100 * result["alpha"],
            "nw_t": result["nw_t"],
            "nw_se": result["nw_se"],
            "N": result["N"],
            "HAC_lags": HAC_LAGS,
            "interpretation": "Intercept tests the difference in WML market-model alphas.",
        })
    extension = pd.DataFrame(rows)
    extension.to_csv(TABLE_DIR / "size_heterogeneity_tests.csv", index=False)
    return extension


def write_summary_stats(all_df: pd.DataFrame, size_df: pd.DataFrame) -> None:
    rows = []
    for name, frame in [("All", all_df), ("Small", size_df[size_df["sizegrp"] == 1]),
                        ("Medium", size_df[size_df["sizegrp"] == 2]),
                        ("Large", size_df[size_df["sizegrp"] == 3])]:
        for col in ["WML", "mkt_return", "rf_decimal"]:
            values = pd.to_numeric(frame[col], errors="coerce").dropna()
            rows.append({
                "sample": name, "variable": col, "N": len(values),
                "mean": values.mean(), "std": values.std(ddof=1),
                "min": values.min(), "median": values.median(), "max": values.max(),
            })
    pd.DataFrame(rows).to_csv(TABLE_DIR / "summary_statistics.csv", index=False)


def make_figures(results: pd.DataFrame) -> None:
    all_rows = results.loc[results["sample"] == "All"].copy()
    labels = all_rows["portfolio"].tolist()
    alphas = 100 * all_rows["alpha"].to_numpy()
    errors = 1.96 * 100 * all_rows["nw_se"].to_numpy()

    fig, ax = plt.subplots(figsize=(10, 5.5))
    positions = np.arange(len(labels))
    ax.errorbar(positions, alphas, yerr=errors, fmt="o", capsize=3)
    ax.axhline(0, linewidth=1)
    ax.set_xticks(positions, labels)
    ax.set_ylabel("Monthly alpha (%)")
    ax.set_xlabel("Momentum portfolio")
    ax.set_title("Full-sample market-model alphas (95% HAC intervals)")
    fig.tight_layout()
    fig.savefig(FIGURE_DIR / "full_sample_alphas.png", dpi=180)
    plt.close(fig)

    spread = results.loc[results["portfolio"] == "WML"].copy()
    order = ["All", "Small", "Medium", "Large"]
    spread["sample"] = pd.Categorical(spread["sample"], categories=order, ordered=True)
    spread = spread.sort_values("sample")
    fig, ax = plt.subplots(figsize=(8, 5))
    x = np.arange(len(spread))
    ax.errorbar(x, 100 * spread["alpha"], yerr=1.96 * 100 * spread["nw_se"], fmt="o", capsize=4)
    ax.axhline(0, linewidth=1)
    ax.set_xticks(x, spread["sample"].astype(str).tolist())
    ax.set_ylabel("Monthly WML alpha (%)")
    ax.set_title("WML alpha by sample and size group (95% HAC intervals)")
    fig.tight_layout()
    fig.savefig(FIGURE_DIR / "wml_alpha_by_size.png", dpi=180)
    plt.close(fig)


def main() -> int:
    TABLE_DIR.mkdir(parents=True, exist_ok=True)
    FIGURE_DIR.mkdir(parents=True, exist_ok=True)
    try:
        all_df, size_df = prepare_inputs()
        results = run_core(all_df, size_df)
        extension = run_size_extension(size_df)
        write_summary_stats(all_df, size_df)
        make_figures(results)
    except (FileNotFoundError, ValueError, KeyError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"Core alpha rows: {len(results)}")
    print(f"Size-extension tests: {len(extension)}")
    print(f"Tables: {TABLE_DIR.relative_to(ROOT)}")
    print(f"Figures: {FIGURE_DIR.relative_to(ROOT)}")
    print("Review all outputs and compare the modern-sample results with the original paper before finalizing the report.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
