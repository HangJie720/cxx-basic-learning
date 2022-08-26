#include <stdio.h> 

#if !(CUDA_NV || CUDA_BI)
//#if !defined(CUDA_BI) || !defined(CUDA_NV)
#define a 10
#else
#define a 5
#endif

int main() 
{ 
    printf("a is: %d \n", a);
    return 0;
}
