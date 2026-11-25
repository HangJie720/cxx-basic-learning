#!/bin/bash
# Batch over ResNet50-like shapes (see resnet50_shapes.tsv).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SHAPES="${ROOT}/resnet50_shapes.tsv"
OUT_DIR="${ROOT}/results_resnet50"
SEED="${SEED:-42}"

if [[ -z "${CUDA_HOME:-}" ]]; then
  if [[ -d /usr/local/cuda-13 ]]; then export CUDA_HOME=/usr/local/cuda-13
  elif [[ -d /usr/local/cuda ]]; then export CUDA_HOME=/usr/local/cuda
  fi
fi
export CUDNN_HOME="${CUDNN_HOME:-${CUDA_HOME}}"
export PATH="${CUDA_HOME}/bin:${PATH:-}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${CUDNN_HOME}/lib64:${CUDNN_HOME}/lib:${LD_LIBRARY_PATH:-}"

bash "${ROOT}/make.sh"
mkdir -p "${OUT_DIR}"
cd "${ROOT}"

echo "SEED=${SEED}"
echo "shapes=${SHAPES}"
echo "out=${OUT_DIR}"

while IFS=$'\t' read -r name shape pad stride || [[ -n "${name:-}" ]]; do
  [[ -z "${name}" || "${name}" =~ ^# ]] && continue
  echo
  echo "========== ${name} shape=${shape} pad=${pad} stride=${stride} =========="
  json="${OUT_DIR}/${name}.json"
  ./conv2d_algo_precision \
    --seed "${SEED}" \
    --shape "${shape}" \
    --pad "${pad}" \
    --stride "${stride}" \
    --baseline self \
    --out "${json}"
done < "${SHAPES}"

python3 "${ROOT}/summarize_resnet50.py" \
  --dir "${OUT_DIR}" \
  -o "${ROOT}/report_resnet50.xlsx"

echo
echo "per-layer json: ${OUT_DIR}/"
echo "summary excel : ${ROOT}/report_resnet50.xlsx"
