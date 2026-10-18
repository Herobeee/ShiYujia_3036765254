#!/usr/bin/env python3
"""Plot the CSV outputs produced by the primary Stata Table III workflow.

This script only visualizes exported estimates. It does not estimate betas,
construct portfolios, or rerun regressions.
Run from the repository root:
    python skills/scripts/plot_table3.py
"""
from __future__ import annotations

import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[2]
TABLES = ROOT / "outputs" / "tables"
FIGURES = ROOT / "outputs" / "figures"
PANEL_A = TABLES / "JT_TableIII_PanelA_daily_beta.csv"
PANEL_B = TABLES / "JT_TableIII_PanelB_daily_beta.csv"
SAMPLE_ORDER = [
    "All", "SizeSmall", "SizeMedium", "SizeLarge",
    "BetaLow", "BetaMedium", "BetaHigh",
]


def read_rows(path: Path) -> list[dict[str, str]]:
    if not path.is_file():
        raise FileNotFoundError(
            f"Missing Stata output: {path.relative_to(ROOT)}. "
            "Run code/stata/00_master.do in Stata 18 first."
        )
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if not rows:
        raise ValueError(f"Output CSV is empty: {path.relative_to(ROOT)}")
    return rows


def number(row: dict[str, str], key: str) -> float:
    try:
        return float(row[key])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(
            f"Expected numeric column {key!r} in Table III CSV."
        ) from exc


def portfolio_label(row: dict[str, str]) -> str:
    value = (row.get("portfolio") or "").strip()
    if value:
        return value
    decile = int(float(row["decile"]))
    return "P10-P1" if decile == 11 else f"P{decile}"


def make_figure(rows: list[dict[str, str]], value_col: str, title: str,
                ylabel: str, filename: str) -> None:
    samples = sorted(
        {row.get("sample", "") for row in rows},
        key=lambda item: SAMPLE_ORDER.index(item) if item in SAMPLE_ORDER else 999,
    )
    fig, axes = plt.subplots(
        nrows=len(samples), ncols=1,
        figsize=(10, max(3.2, 2.8 * len(samples))),
        sharex=True, squeeze=False,
    )
    for ax, sample in zip(axes[:, 0], samples):
        selected = [row for row in rows if row.get("sample", "") == sample]
        selected.sort(key=lambda row: int(float(row["decile"])))
        labels, values, errors = [], [], []
        for row in selected:
            estimate = number(row, value_col)
            t_stat = number(row, "t_stat")
            labels.append(portfolio_label(row))
            values.append(estimate * 100)
            errors.append((abs(estimate / t_stat) * 1.96 * 100) if t_stat != 0 else 0.0)
        positions = list(range(len(labels)))
        ax.errorbar(positions, values, yerr=errors, fmt="o", capsize=3)
        ax.axhline(0, linewidth=1)
        ax.set_ylabel(f"{sample}\n{ylabel}")
        ax.grid(axis="y", alpha=0.25)
    axes[-1, 0].set_xticks(
        list(range(len(labels))), labels, rotation=0
    )
    axes[-1, 0].set_xlabel("Momentum portfolio")
    fig.suptitle(title)
    fig.tight_layout()
    FIGURES.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIGURES / filename, dpi=180, bbox_inches="tight")
    plt.close(fig)


def main() -> int:
    panel_a = read_rows(PANEL_A)
    panel_b = read_rows(PANEL_B)
    make_figure(
        panel_a, "mean_ret",
        "Table III Panel A: raw portfolio returns by beta/size sample",
        "Mean return (%)", "table3_panelA_raw_returns.png",
    )
    make_figure(
        panel_b, "alpha",
        "Table III Panel B: CAPM alphas by beta/size sample",
        "Alpha (%)", "table3_panelB_alphas.png",
    )
    print("Created:")
    print("  outputs/figures/table3_panelA_raw_returns.png")
    print("  outputs/figures/table3_panelB_alphas.png")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
