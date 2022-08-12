# nvcc -std=c++11 -gencode arch=compute_70,code=sm_70 -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart test.cu -o test_nv
clang++ -std=c++11 --cuda-gpu-arch=sm_70 --cuda-path=/usr/local/cuda -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart test.cu -o test_nv
