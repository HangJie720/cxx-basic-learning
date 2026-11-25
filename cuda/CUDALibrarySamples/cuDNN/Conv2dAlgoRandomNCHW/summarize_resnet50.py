#!/usr/bin/env python3
"""汇总 ResNet50 各层多算法精度结果为单表 Excel。"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter


HEADER_FILL = PatternFill("solid", fgColor="1F4E79")
HEADER_FONT = Font(color="FFFFFF", bold=True)
OK_FILL = PatternFill("solid", fgColor="C6EFCE")
DIFF_FILL = PatternFill("solid", fgColor="FCE4D6")
THIN = Border(
    left=Side(style="thin", color="B0B0B0"),
    right=Side(style="thin", color="B0B0B0"),
    top=Side(style="thin", color="B0B0B0"),
    bottom=Side(style="thin", color="B0B0B0"),
)

HEADERS = [
    "layer",
    "shape_x",
    "shape_w",
    "pad",
    "stride",
    "Get",
    "Find",
    "supported_algos",
    "all_exact",
    "diff_pairs",
    "max_abs_among_supported",
    "max_neq_among_supported",
]


def autosize(ws) -> None:
    for col in ws.columns:
        letter = get_column_letter(col[0].column)
        w = 10
        for cell in col:
            if cell.value is not None:
                w = max(w, min(48, len(str(cell.value)) + 2))
        ws.column_dimensions[letter].width = w


def summarize(dir_path: Path, out_xlsx: Path) -> None:
    files = sorted(dir_path.glob("*.json"))
    if not files:
        raise SystemExit(f"no json in {dir_path}")

    wb = Workbook()
    ws = wb.active
    ws.title = "ResNet50"
    ws.append(HEADERS)
    for c in range(1, len(HEADERS) + 1):
        cell = ws.cell(1, c)
        cell.fill = HEADER_FILL
        cell.font = HEADER_FONT
        cell.alignment = Alignment(horizontal="center", wrap_text=True)
        cell.border = THIN

    for fp in files:
        d = json.loads(fp.read_text(encoding="utf-8"))
        sh = d.get("shape") or {}
        runs = [r for r in d.get("runs", []) if r.get("ok")]
        supported = ",".join(f"{r['algo']}" for r in runs)
        pairs = d.get("pairwise") or []
        diff_pairs = []
        max_abs = 0.0
        max_neq = 0
        for p in pairs:
            if not p.get("exact"):
                diff_pairs.append(f"{p.get('a_algo')}vs{p.get('b_algo')}")
                max_abs = max(max_abs, float(p.get("max_abs") or 0))
                max_neq = max(max_neq, int(p.get("non_equal") or 0))
        all_exact = bool(d.get("all_supported_algos_exact_to_baseline"))
        row = [
            fp.stem,
            f"{sh.get('n')}x{sh.get('c')}x{sh.get('h')}x{sh.get('w')}",
            f"{sh.get('k')}x{sh.get('c')}x{sh.get('r')}x{sh.get('s')}",
            f"{sh.get('pad_h')},{sh.get('pad_w')}",
            f"{sh.get('stride_h')},{sh.get('stride_w')}",
            f"{d.get('get_selected_algo')} {d.get('get_selected_algo_name')}",
            f"{d.get('find_selected_algo')} {d.get('find_selected_algo_name')}",
            supported,
            "YES" if all_exact else "NO",
            ",".join(diff_pairs) if diff_pairs else "",
            max_abs if diff_pairs else 0,
            max_neq if diff_pairs else 0,
        ]
        ws.append(row)
        fill = OK_FILL if all_exact else DIFF_FILL
        for c in range(1, len(HEADERS) + 1):
            cell = ws.cell(ws.max_row, c)
            cell.border = THIN
            cell.alignment = Alignment(horizontal="center", wrap_text=True)
            cell.fill = fill

    n_ok = sum(1 for r in ws.iter_rows(min_row=2, max_col=9, values_only=True) if r[8] == "YES")
    n_all = ws.max_row - 1
    ws.append([])
    ws.append(["summary", f"layers={n_all}", f"all_exact={n_ok}", f"has_diff={n_all - n_ok}"])
    autosize(ws)
    out_xlsx.parent.mkdir(parents=True, exist_ok=True)
    wb.save(out_xlsx)
    print(f"wrote {out_xlsx} ({n_ok}/{n_all} layers all_exact)")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", type=Path, required=True)
    ap.add_argument("-o", "--output", type=Path, required=True)
    args = ap.parse_args()
    summarize(args.dir, args.output)


if __name__ == "__main__":
    main()
