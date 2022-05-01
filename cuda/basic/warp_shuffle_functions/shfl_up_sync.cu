#include <stdio.h>

__global__ void scan4() {
    int laneId = threadIdx.x & 0x1f; // 0001 1111;
    // Seed sample starting value (inverse of lane ID)
    int value = 31 - laneId;

    // Loop 0o accumulate scan within my partition.
    // Scan requires log2(n) == 3 steps for 8 threads
    // It works by an accumulated sum up the warp
    // by 1, 2, 4, 8 etc. steps.
    for (int i=1; i<=4; i*=2) {
        // We do the __shfl_sync unconditionally so that we
        // can read even from threads which won't do a
        // sum, and then conditionally assign the result.
        int n = __shfl_up_sync(0xffffffff, value, i, 8);
        if ((laneId & 7) >= i) // 0000 0111;
            value += n;
    }
    /*
v=  31 30 29  28  27  26  25  24 23 22 21 20  19  18  17  16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
n=  31 31 30  29  28  27  26  25 23 23 22 21  20  19  18  17 15 15 14 13 12 11 10  9  7  7  6  5  4  3  2  1
    
v=  31 61 59  57  55  53  51  49 23 45 43 41  39  37  35  33 15 29 27 25 23 21 19 17  7 13 11  9  7  5  3  1
n=  31 61 31  61  59  57  55  53 23 45 23 45  43  41  39  37 15 29 15 29 27 25 23 21  7 13  7 13 11  9  7  5

v=  31 61 90 118 114 110 106 102 23 45 66 86  82  78  74  70 15 29 42 54 50 46 42 38  7 13 18 22 18 14 10  6
n=  31 61 90 118  31  61  90 118 23 45 66 86  23  45  66  86 15 29 42 54 15 29 42 54  7 13 18 22  7 13 18 22

v=  31 61 90 118 145 171 196 220 23 45 66 86 105 123 140 156 15 29 42 54 65 75 84 92  7 13 18 22 25 27 28 28
    */
    printf("Thread %d final value = %d\n", threadIdx.x, value);
}

int main() {
    scan4<<< 1, 32 >>>();
    cudaDeviceSynchronize();

    return 0;
}