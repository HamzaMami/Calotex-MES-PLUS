"""
Extract production orders from the Calotex FORM -PRO-01 Excel sheet.

Reads the 'pA' worksheet, starting at row index 4 (0-based), parses all
valid order rows, and produces a clean per-order summary with quantities.
The total quantity sum is printed for feeding the Calotex MES export-progress
target.
"""

from __future__ import annotations

import json
import os
import re
import sys

import pandas as pd

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SHEET_NAME = "pA"
HEADER_ROW = 4  # 0-based row index that holds the column headers
ORDER_COL = 0   # first column  -> Order Numbers
QTY_COL = 7     # "Qté" column

# Substrings that identify footer / metadata rows to skip.
FOOTER_KEYWORDS = {"Version", "Date", "Contrôlé", "Approuvé", "Créé par"}
HEADER_TEXT = "N° de commande"  # the sub-header value in the first data row


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _clean_order_number(raw: str) -> str:
    """Strip the trailing line/version suffix (e.g. '  1,0').

    Values in the source look like  '11005176   1,0'  or  'MBA 6412   1,0'.
    The numeric prefix before the suffix is the real order number.
    """
    return re.sub(r"\s+\d+,\d+\s*$", "", raw).strip()


def _is_valid_row(col0: object, col7: object) -> bool:
    """Return True only for rows that represent actual order data."""
    if pd.isna(col0) or pd.isna(col7):
        return False
    col0_str = str(col0).strip()
    if col0_str == HEADER_TEXT:
        return False
    if any(kw in col0_str for kw in FOOTER_KEYWORDS):
        return False
    return True


def _parse_quantity(value: object) -> float | None:
    """Convert a quantity cell to float, returning None on failure."""
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


# ---------------------------------------------------------------------------
# Main extraction
# ---------------------------------------------------------------------------

def extract_orders(excel_path: str) -> pd.DataFrame:
    """Load the Excel sheet and return a clean dataframe of orders."""
    df = pd.read_excel(excel_path, sheet_name=SHEET_NAME, header=HEADER_ROW)

    records: list[dict[str, object]] = []

    for _, row in df.iterrows():
        col0 = row.iloc[ORDER_COL]
        col7 = row.iloc[QTY_COL]

        if not _is_valid_row(col0, col7):
            continue

        order_number = _clean_order_number(str(col0))
        if not order_number:
            continue

        qty = _parse_quantity(col7)
        if qty is None:
            continue

        records.append({"order_number": order_number, "quantity": qty})

    orders = pd.DataFrame(records, columns=["order_number", "quantity"])

    # Aggregate quantities for the same order number (different line numbers).
    summary = (
        orders.groupby("order_number", as_index=False)["quantity"]
        .sum()
        .sort_values("order_number")
        .reset_index(drop=True)
    )
    summary["quantity"] = summary["quantity"].astype(int)
    return summary


def _find_excel() -> str | None:
    """Locate the FORM -PRO-01 Excel file inside the data directory."""
    data_dir = os.path.join(SCRIPT_DIR, "data")
    if not os.path.isdir(data_dir):
        return None
    for name in os.listdir(data_dir):
        if name.startswith("FORM") and name.lower().endswith(".xlsx"):
            return os.path.join(data_dir, name)
    return None


def main() -> None:
    excel_path = _find_excel()
    if excel_path is None or not os.path.isfile(excel_path):
        print(f"ERROR: Excel file not found in {os.path.join(SCRIPT_DIR, 'data')}", file=sys.stderr)
        sys.exit(1)

    summary = extract_orders(excel_path)

    print("=" * 60)
    print("Distinct Order Numbers and Quantities")
    print("=" * 60)
    print(summary.to_string(index=False))
    print("=" * 60)

    total = int(summary["quantity"].sum())
    print(f"\nTotal quantity sum: {total}")
    print(f"  (expected: 270 for Calotex MES export progress target)")

    # Write a CSV next to the script for easy integration.
    csv_path = os.path.join(SCRIPT_DIR, "order_summary.csv")
    summary.to_csv(csv_path, index=False)
    print(f"\nCSV summary written to: {csv_path}")

    # Write a JSON next to the script for dashboard integration.
    json_path = os.path.join(SCRIPT_DIR, "order_summary.json")
    records = summary.to_dict(orient="records")
    with open(json_path, "w", encoding="utf-8") as fh:
        json.dump(records, fh, indent=2, ensure_ascii=False)
    print(f"JSON summary written to: {json_path}")


if __name__ == "__main__":
    main()
