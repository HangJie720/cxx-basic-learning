#include <cuda_runtime.h>
#include <iostream>

__global__ void new_test(float a, float b)
{
    // 1e-37
    printf("a is: %.50f \n", a);
    printf("b is: %.50f \n", b);
    float ftmp_a = a;
    uint32_t *tmp_a = (uint32_t*)&ftmp_a;
    printf("float a is: 0x %x \n", *tmp_a);

    // 1e-38
    float ftmp_b = b;
    uint32_t *tmp_b = (uint32_t*)&ftmp_b;
    printf("float b is: 0x %x \n", *tmp_b);
}

__global__ void new_test2()
{
    // 1e-37

    unsigned tmp = 0x2081cea;
    float *a = (float *)&tmp;
    if (*a != float(0)) {
      printf("1e-37 Binary op\n");
    } else {
      printf("1e-37 Zero op\n");
    }
    unsigned tmp2 = 0x6ce3ee;
    float *b = (float *)&tmp2;
    if (*b != float(0)) {
      printf("1e-38 Binary op\n");
    } else {
      printf("1e-38 Zero op\n");
    }
}

int main(){
    float a = 1.0e-45;
    float b = 1.0e-45;

    // new_test<<<1,1>>>(a, b);
    new_test2<<<1,1>>>();
    cudaDeviceSynchronize();
    return 0;
}