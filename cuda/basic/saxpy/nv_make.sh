#clang++ -std=c++11 -g saxpy.cu -o test_floatdiv -I./ --cuda-gpu-arch=sm_70 --cuda-path=/usr/local/cuda/ -ldl -fPIC -pthread -L/usr/local/cuda/lib64 -lcudart
nvcc -std=c++11 -gencode arch=compute_70,code=sm_70 -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart saxpy.cu -o test_float2int
