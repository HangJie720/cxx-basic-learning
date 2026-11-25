#!/bin/bash
# Sweep all FWD algos on a golden NCDHW case; baseline = Get_v7 / self ref.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "${CUDA_HOME:-}" ]]; then
  if [[ -d /usr/local/cuda-13 ]]; then
    export CUDA_HOME=/usr/local/cuda-13
  elif [[ -d /usr/local/cuda ]]; then
    export CUDA_HOME=/usr/local/cuda
  fi
fi
export CUDNN_HOME="${CUDNN_HOME:-${CUDA_HOME}}"
export PATH="${CUDA_HOME}/bin:${PATH:-}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${CUDNN_HOME}/lib64:${CUDNN_HOME}/lib:${LD_LIBRARY_PATH:-}"

GOLDEN="${GOLDEN:-${ROOT}/golden}"
if [[ ! -f "${GOLDEN}/padded.bf16.bin" ]]; then
  echo "missing input tensors under ${GOLDEN}"
  echo "provide golden/ with padded.bf16.bin weight.bf16.bin bias.bf16.bin"
  exit 1
fi

bash "${ROOT}/make.sh"
cd "${ROOT}"

JSON="${ROOT}/summary.json"
XLSX="${ROOT}/report.xlsx"
SAVE_GOLDEN="${ROOT}/out_golden"

./conv3d_algo_precision "${GOLDEN}" \
  --algos all \
  --baseline self \
  --ref-algo auto \
  --save-golden "${SAVE_GOLDEN}" \
  --out "${JSON}"

if ! python3 -c "import openpyxl" >/dev/null 2>&1; then
  python3 -m pip install --user -q openpyxl || pip3 install --user -q openpyxl
fi
python3 "${ROOT}/export_excel.py" "${JSON}" -o "${XLSX}"

echo
echo "summary : ${JSON}"
echo "excel   : ${XLSX}"
echo "out ref : ${SAVE_GOLDEN}"
