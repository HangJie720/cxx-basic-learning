#include <iostream>
#include <cmath>
#include <cstdint>
#include <cstring>
// #include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

#define C10_WARP_SIZE warpSize

int main()
{
    printf("warpSize is: %d \n", C10_WARP_SIZE);
}