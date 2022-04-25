#!/bin/bash

nvcc -std=c++11 -gencode arch=compute_70,code=sm_70 -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart test_atomicCASUInt64.cu -o nv_atomicCASUInt64


