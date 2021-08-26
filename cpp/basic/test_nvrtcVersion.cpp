#include <stdio.h>
#include <iostream>
#include <nvrtc.h>
using namespace std;

#define AT_CUDA_NVRTC_CHECK(EXPR)                                                                   \
  do {                                                                                              \
    nvrtcResult __err = EXPR;                                                                       \
    printf("EXPR: %d \n", EXPR); \
    if (__err != NVRTC_SUCCESS) {                                                                   \
      if (static_cast<int>(__err) != 7) {                                                           \
        printf("CUDA NVRTC error 1111");  \
      } else {                                                                                      \
        printf("CUDA NVRTC error: NVRTC_ERROR_BUILTIN_OPERATION_FAILURE");                        \
      }                                                                                             \
    }                                                                                               \
  } while (0)

int main(){
  int major;
  int minor;  
  nvrtcVersion(&major, &minor);
  printf("major is: %d \n", major);
  printf("minor is: %d \n", minor);
}
