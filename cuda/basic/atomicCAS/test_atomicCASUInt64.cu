#include <stdio.h>
#include <stdint.h>
#include <algorithm>
#include <time.h>
#include <random>
using namespace std;
const int blocksize = 256;
const int factor = 4;
const int arraysize = blocksize / factor;

__device__ unsigned long long int atomicCAS1(unsigned long long int *address, unsigned long long int compare, unsigned long long int val){
    uint2* address_uint2 = reinterpret_cast<uint2 *>(address);
    const uint2 compare_uint2 = reinterpret_cast<uint2&>(compare);
    const uint2 val_uint2 = reinterpret_cast<uint2&>(val);
    int64_t old1;
    uint2 old1_uint2 = reinterpret_cast<uint2&>(old1);
    old1_uint2.x = atomicCAS(&((*address_uint2).x), compare_uint2.x, val_uint2.x);
    old1_uint2.y = atomicCAS(&((*address_uint2).y), compare_uint2.y, val_uint2.y);
    return old1;
}

__device__ void gpuAtomicAdd(int64_t *address, int64_t val) {
    unsigned long long * address_as_ui = (unsigned long long *) (address);
    unsigned long long old = *address_as_ui;
    unsigned long long newval;
    unsigned long long assumed;

    do {
      assumed = old;
      newval = val +  (int64_t)old;
      old = atomicCAS1(address_as_ui, assumed, newval);
    } while (assumed != old);
  }

__device__ void gpuAtomicAdd(int64_t *address)
{
    unsigned long long *address_as_ui = (unsigned long long *)(address);
    unsigned long long old = *address_as_ui;
    unsigned long long newval;
    unsigned long long assumed;

    do
    {
        assumed = old;
        newval = old + 1;
        old = atomicCAS(address_as_ui, assumed, newval);
    } while (assumed != old);
}

#if 0
__device__ void gpuAtomicAdd(int64_t *address, int64_t val) {
  uint2* address_uint2 = reinterpret_cast<uint2 *>(address);
  const uint2 val_uint2 = reinterpret_cast<uint2&>(val);
  if (atomicAdd(&((*address_uint2).x), val_uint2.x)+ val_uint2.x < val_uint2.x)
    atomicAdd(&((*address_uint2).y), 1);
  atomicAdd(&((*address_uint2).y), val_uint2.y);
}
#endif
__global__ void addition_test_kernel(int64_t *sum)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int idx = (tid) % arraysize;

    gpuAtomicAdd(&sum[idx], 1);
}

int main(int argc, char **argv)
{
    dim3 dimBlock(blocksize, 1);
    dim3 dimGrid(1, 1);
    printf( "sizeof %lu\n",sizeof(int64_t));

    int64_t *sum, *answer, *sumd;

    sum = (int64_t *)malloc(arraysize * sizeof(int64_t));
    answer = (int64_t *)malloc(arraysize * sizeof(int64_t));

    for (int i = 0; i < arraysize; ++i)
    {
        sum[i] = 0;
        answer[i] = factor;
    }

    cudaMalloc((void **)&sumd, arraysize * sizeof(int64_t));

    cudaMemcpy(sumd, sum, arraysize * sizeof(int64_t), cudaMemcpyHostToDevice);
    printf("start!\n");
    addition_test_kernel<<<dimGrid, dimBlock>>>(sumd);
    cudaMemcpy(sum, sumd, arraysize * sizeof(int64_t), cudaMemcpyDeviceToHost);
    printf("finish!\n");

    for (int i = 0; i < arraysize; ++i)
    {
        printf("%ld,", sum[i]);
    }
    printf("\n");
    cudaFree(sumd);
    free(sum);
    free(answer);
    return 0;
}
