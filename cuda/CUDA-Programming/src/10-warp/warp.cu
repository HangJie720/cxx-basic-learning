#include "error.cuh"
#include <stdio.h>

const unsigned WIDTH = 8;
const unsigned BLOCK_SIZE = 16;
const unsigned FULL_MASK = 0xffffffff;

void __global__ test_warp_primitives(void);

int main(int argc, char **argv)
{
    test_warp_primitives<<<1, BLOCK_SIZE>>>();
    CHECK(cudaDeviceSynchronize());
    return 0;
}

void __global__ test_warp_primitives(void)
{
    int tid = threadIdx.x;
    int lane_id = tid % WIDTH;

    if (tid == 0) printf("threadIdx.x: ");
    printf("%2d ", tid);
    if (tid == 0) printf("\n");

    if (tid == 0) printf("lane_id:     ");
    printf("%2d ", lane_id);
    if (tid == 0) printf("\n");

    unsigned mask1 = __ballot_sync(FULL_MASK, tid > 0);
    unsigned mask2 = __ballot_sync(FULL_MASK, tid == 0);
    if (tid == 0) printf("FULL_MASK = %x\n", FULL_MASK);
    if (tid == 1) printf("mask1     = %x\n", mask1);
    if (tid == 0) printf("mask2     = %x\n", mask2);

    int result = __all_sync(FULL_MASK, tid);
    if (tid == 0) printf("all_sync (FULL_MASK): %d\n", result);

    result = __all_sync(mask1, tid);
    if (tid == 1) printf("all_sync     (mask1): %d\n", result);

    result = __any_sync(FULL_MASK, tid);
    if (tid == 0) printf("any_sync (FULL_MASK): %d\n", result);

    result = __any_sync(mask2, tid);
    if (tid == 0) printf("any_sync     (mask2): %d\n", result);

    int value = __shfl_sync(FULL_MASK, tid, 2, WIDTH);
    if (tid == 0) printf("shfl:      ");
    printf("%2d ", value);
    if (tid == 0) printf("\n");

    value = __shfl_up_sync(FULL_MASK, tid, 1, WIDTH);
    if (tid == 0) printf("shfl_up:   ");
    printf("%2d ", value);
    if (tid == 0) printf("\n");

    value = __shfl_down_sync(FULL_MASK, tid, 1, WIDTH);
    if (tid == 0) printf("shfl_down: ");
    printf("%2d ", value);
    if (tid == 0) printf("\n");

    value = __shfl_xor_sync(FULL_MASK, tid, 1, WIDTH);
    if (tid == 0) printf("shfl_xor:  ");
    printf("%2d ", value);
    if (tid == 0) printf("\n");
}


/*
threadIdx.x:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
lane_id:      0  1  2  3  4  5  6  7  0  1  2  3  4  5  6  7
FULL_MASK = ffffffff
mask1     = fffe
mask2     = 1
all_sync (FULL_MASK): 0
all_sync     (mask1): 1
any_sync (FULL_MASK): 1
any_sync     (mask2): 0
shfl:       2  2  2  2  2  2  2  2 10 10 10 10 10 10 10 10
shfl_up:    0  0  1  2  3  4  5  6  8  8  9 10 11 12 13 14
shfl_down:  1  2  3  4  5  6  7  7  9 10 11 12 13 14 15 15
shfl_xor:   1  0  3  2  5  4  7  6  9  8 11 10 13 12 15 14
*/