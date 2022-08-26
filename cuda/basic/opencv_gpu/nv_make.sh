#!/bin/bash

clang++ -std=c++11 -g test.cpp -o test \
        --cuda-gpu-arch=sm_70 \
        --cuda-path=/usr/local/cuda/ \
        -I/usr/local/include/opencv4 \
        -I/usr/local/cuda/include \
        -L/usr/local/lib \
        -L/usr/local/cuda/lib64 \
        -lcudart \
        -lopencv_core \
        -lopencv_highgui \
        -lopencv_imgcodecs \
        -lopencv_videoio \
        -lopencv_shape \
        -lopencv_cudaarithm