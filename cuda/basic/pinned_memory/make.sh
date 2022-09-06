#! /bin/bash
CUDA_DIR=/usr/local/cuda

clang++ -std=c++11 --cuda-gpu-arch=sm_70 --cuda-path=${CUDA_DIR} -I${CUDA_DIR}/include -L${CUDA_DIR}/lib64 -lcudart bandwidthtest.cu -o bandwidthtest
