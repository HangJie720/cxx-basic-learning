#include <stdio.h>
#include <stdlib.h>

#define LOG_FATAL(msg) LogMessageFatal(__FILE__, __LINE__, msg)
__device__ void LogMessageFatal(const char* file, int line, const char* msg) {
  printf("FATAL: [%s:%d] %s\n", file, line, msg);
  //asm volatile("sl_trap_ent 0;");
  asm volatile("trap;");
  printf("aaaaaaa \n");
}

__device__ void abc1(){
  LOG_FATAL("abc is not implemented.");
}

__global__ void launch1(){
  abc1();
}

int main(){
  launch1<<<1,10>>>();
  cudaError error = cudaDeviceSynchronize();

  printf("error is: %d \n", error);
  return 0;
}
