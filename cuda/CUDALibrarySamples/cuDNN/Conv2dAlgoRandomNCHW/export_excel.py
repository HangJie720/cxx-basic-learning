#!/usr/bin/env python3
"""
把 C++ summary JSON 导出为单表 Excel。

用法:
  python3 export_excel.py summary_cpp_nv.json -o report_nv.xlsx
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter


HEADER_FILL = PatternFill("solid", fgColor="1F4E79")
HEADER_FONT = Font(color="FFFFFF", bold=True)
GET_FILL = PatternFill("solid", fgColor="FFF2CC")
FIND_FILL = PatternFill("solid", fgColor="E2EFDA")
BOTH_FILL = PatternFill("solid", fgColor="DDEBF7")
FAIL_FILL = PatternFill("solid", fgColor="FCE4D6")
THIN = Border(
    left=Side(style="thin", color="B0B0B0"),
    right=Side(style="thin", color="B0B0B0"),
    top=Side(style="thin", color="B0B0B0"),
    bottom=Side(style="thin", color="B0B0B0"),
)

HEADERS = [
    "algo",
    "Get",
    "Find",
    "ok",
    "status",
    "exact",
    "non_equal",
    "mae",
    "max_abs",
    "mean_rel",
    "max_rel",
    "rel_l2",
    "cosine_sim",
    "pearson",
    "similarity",
    "time_ms",
    "get_rank",
    "find_rank",
]


def autosize(ws, min_w=10, max_w=40) -> None:
    for col in ws.columns:
        letter = get_column_letter(col[0].column)
        width = min_w
        for cell in col:
            if cell.value is None:
                continue
            width = max(width, min(max_w, len(str(cell.value)) + 2))
        ws.column_dimensions[letter].width = width


def export(summary_path: Path, out_path: Path) -> None:
    data = json.loads(summary_path.read_text(encoding="utf-8"))
    wb = Workbook()
    ws = wb.active
    ws.title = "Summary"

    ws.append(HEADERS)
    for col in range(1, len(HEADERS) + 1):
        cell = ws.cell(1, col)
        cell.fill = HEADER_FILL
        cell.font = HEADER_FONT
        cell.alignment = Alignment(horizontal="center", wrap_text=True)
        cell.border = THIN

    for r in data.get("runs", []):
        g = r.get("vs_golden") or {}
        ok = bool(r.get("ok"))
        algo_label = f"{r.get('algo')} {r.get('algo_name')}"
        if ok:
            metrics = [
                "exact" if g.get("exact") else "NO",
                g.get("non_equal"),
                g.get("mae"),
                g.get("max_abs"),
                g.get("mean_rel"),
                g.get("max_rel"),
                g.get("rel_l2"),
                g.get("cosine_sim"),
                g.get("pearson"),
                g.get("similarity"),
                r.get("time_ms"),
            ]
            status = r.get("status") or "ok"
        else:
            metrics = ["", "", "", "", "", "", "", "", "", "", ""]
            status = r.get("status") or "不支持/报错"

        row = [
            algo_label,
            "YES" if r.get("selected_by_get") else "",
            "YES" if r.get("selected_by_find") else "",
            "YES" if ok else "NO",
            status,
        ] + metrics + [
            r.get("get_rank"),
            r.get("find_rank"),
        ]
        ws.append(row)

        fill = None
        if not ok:
            fill = FAIL_FILL
        elif r.get("selected_by_get") and r.get("selected_by_find"):
            fill = BOTH_FILL
        elif r.get("selected_by_get"):
            fill = GET_FILL
        elif r.get("selected_by_find"):
            fill = FIND_FILL
        for col in range(1, len(HEADERS) + 1):
            cell = ws.cell(ws.max_row, col)
            cell.border = THIN
            cell.alignment = Alignment(horizontal="center", wrap_text=True)
            if fill:
                cell.fill = fill

    ws.append([])
    ws.append(["device", data.get("device")])
    ws.append(["golden_dir", data.get("golden_dir")])
    ws.append(["baseline_mode", data.get("baseline_mode")])
    ws.append(
        [
            "baseline_algo",
            f"{data.get('baseline_algo')} {data.get('baseline_algo_name')}",
        ]
    )
    ws.append(
        [
            "all_supported_exact_to_baseline",
            data.get("all_supported_algos_exact_to_baseline"),
        ]
    )
    ws.append(
        [
            "Get_v7",
            f"{data.get('get_selected_algo')} {data.get('get_selected_algo_name')}",
        ]
    )
    ws.append(
        [
            "FindEx",
            f"{data.get('find_selected_algo')} {data.get('find_selected_algo_name')}",
        ]
    )
    if data.get("save_golden_dir"):
        ws.append(["save_golden_dir", data.get("save_golden_dir")])

    autosize(ws)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    wb.save(out_path)
    print(f"wrote {out_path}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("summary_json", type=Path)
    ap.add_argument("-o", "--output", type=Path, default=None)
    args = ap.parse_args()
    out = args.output or args.summary_json.with_suffix(".xlsx")
    export(args.summary_json, out)


if __name__ == "__main__":
    main()
