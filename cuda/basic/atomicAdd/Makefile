ROOT ?= /usr/local
CUDA_PATH ?= $(ROOT)/cuda

CUDALIB_PATH := $(CUDA_PATH)/lib64

CXXFLAGS := -I$(CUDA_PATH)/include -gencode=arch=compute_70,code=sm_70

LDFLAGS := -L"$(CUDALIB_PATH)" -lcudart

COMPILER_BIN_PATH := $(ROOT)/bin

NVCC := $(CUDA_PATH)/bin/nvcc


kernel := atomicAdd
cu_src := $(kernel).cu

all: Makefile $(cu_src)
	LD_LIBRARY_PATH="$(CUDALIB_PATH)" $(NVCC) $(CXXFLAGS) $(LDFLAGS) $(cu_src) -o a.out

run: Makefile
	LD_LIBRARY_PATH="$(CUDALIB_PATH)" ./a.out
