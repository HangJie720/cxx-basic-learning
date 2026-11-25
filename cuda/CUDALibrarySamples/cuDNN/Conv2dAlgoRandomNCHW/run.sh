#!/bin/bash
# Random NCHW Conv2d: sweep FWD algos and check consistency across supported ones.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "${CUDA_HOME:-}" ]]; then
  if [[ -d /usr/local/cuda-13 ]]; then export CUDA_HOME=/usr/local/cuda-13
  elif [[ -d /usr/local/cuda ]]; then export CUDA_HOME=/usr/local/cuda
  fi
fi
export CUDNN_HOME="${CUDNN_HOME:-${CUDA_HOME}}"
export PATH="${CUDA_HOME}/bin:${PATH:-}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${CUDNN_HOME}/lib64:${CUDNN_HOME}/lib:${LD_LIBRARY_PATH:-}"

SEED="${SEED:-1234}"
SHAPE="${SHAPE:-2,64,56,56,128,3,3}"

bash "${ROOT}/make.sh"
cd "${ROOT}"

JSON="${ROOT}/summary.json"
XLSX="${ROOT}/report.xlsx"
GOLDEN="${ROOT}/golden"

./conv2d_algo_precision \
  --seed "${SEED}" \
  --shape "${SHAPE}" \
  --baseline self \
  --save-golden "${GOLDEN}" \
  --out "${JSON}"

if ! python3 -c "import openpyxl" >/dev/null 2>&1; then
  python3 -m pip install --user -q openpyxl || pip3 install --user -q openpyxl
fi
python3 "${ROOT}/export_excel.py" "${JSON}" -o "${XLSX}"

echo
echo "summary : ${JSON}"
echo "excel   : ${XLSX}"
echo "golden  : ${GOLDEN}"
echo "seed=${SEED} shape=${SHAPE}"
