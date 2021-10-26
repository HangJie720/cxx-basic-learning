clang++ main.cu -o main --cuda-gpu-arch=sm_61 --cuda-path=/usr/local/cuda/ -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart
