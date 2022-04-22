#include <iostream>
#include <stdio.h>
#include <cuda_runtime.h>
// #include <assert.h>

extern "C" {
void __assert_fail(
        const char* assertion,
        const char* file,
        unsigned int line,
        const char* function) throw() __attribute__((__noreturn__));
}

#define assert(cond)                                         \
    __assert_fail(                                                       \
        #cond, __FILE__, static_cast<unsigned int>(__LINE__), __func__); \

__global__ void test(){
    int a = 0;
    assert(a != 0);
}
int main(int argc, char **argv){
    test<<<1,1>>>();
    cudaDeviceSynchronize();
}