#!/bin/bash
# Build conv2d_algo_precision against NVIDIA CUDA + cuDNN.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [[ -z "${CUDA_HOME:-}" ]]; then
  if [[ -d /usr/local/cuda-13 ]]; then
    CUDA_HOME=/usr/local/cuda-13
  elif [[ -d /usr/local/cuda ]]; then
    CUDA_HOME=/usr/local/cuda
  else
    echo "set CUDA_HOME"; exit 1
  fi
fi
CUDNN_HOME="${CUDNN_HOME:-${CUDA_HOME}}"
ARCH="${NV_GPU_ARCH:-sm_80}"

export PATH="${CUDA_HOME}/bin:${PATH}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${CUDNN_HOME}/lib64:${CUDNN_HOME}/lib:${LD_LIBRARY_PATH:-}"

echo "CUDA_HOME=${CUDA_HOME}"
nvcc --version | head -3
nvcc -std=c++14 \
  -gencode "arch=compute_${ARCH#sm_},code=${ARCH}" \
  -I"${CUDA_HOME}/include" -I"${CUDNN_HOME}/include" \
  -L"${CUDA_HOME}/lib64" -L"${CUDNN_HOME}/lib64" -L"${CUDNN_HOME}/lib" \
  -lcudart -lcudnn -O2 \
  "${ROOT}/conv2d_algo_precision.cu" -o "${ROOT}/conv2d_algo_precision"
echo "built ${ROOT}/conv2d_algo_precision"
