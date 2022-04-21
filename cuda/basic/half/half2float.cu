// #include <cuda_fp16.h> 
#include <iostream>

#define NAN __int_as_float(0x7fffffff)
#define POS_INFINITY __int_as_float(0x7f800000)
#define NEG_INFINITY __int_as_float(0xff800000)

template<typename T>
__device__ T maximum(T a, T b) {   return isnan(a) ? a : (a > b ? a : b);
}

template<typename T>
__device__ T minimum(T a, T b) {
  return isnan(a) ? a : (a < b ? a : b);
}


#define __HALF_TO_US(var) *(reinterpret_cast<unsigned short *>(&(var)))
#define __HALF_TO_CUS(var) *(reinterpret_cast<const unsigned short *>(&(var)))
#if defined(__cplusplus)
  struct __align__(2) __half {
    __host__ __device__ __half() { }

  protected:
    unsigned short __x;
  };

  /* All intrinsic functions are only available to nvcc compilers */
  #if defined(__CUDACC__)
    /* Definitions of intrinsics */
    __device__ __half __float2half(const float f) {
      __half val;
      #ifndef __ILUVATAR__
        asm("{  cvt.rn.f16.f32 %0, %1;}\n" : "=h"(__HALF_TO_US(val)) : "f"(f));
      #else
        __fp16 ha = f;
        val = reinterpret_cast<__half &>(ha);
      #endif
      return val;
    }

    __device__ float __half2float(const __half h) {
      float val;
      #ifndef __ILUVATAR__
        asm("{  cvt.f32.f16 %0, %1;}\n" : "=f"(val) : "h"(__HALF_TO_CUS(h)));
      #else
        const __fp16 ha = reinterpret_cast<const __fp16 &>(h);
        val = ha;
      #endif
      return val;
    }
  #endif /* defined(__CUDACC__) */
#endif /* defined(__cplusplus) */
#undef __HALF_TO_US
#undef __HALF_TO_CUS

__global__ void test(__half *in, int* out) {

  *out = (int) (__half2float(*in));
}

int main() {

  __half in_init = __float2half(0.3);
  std::cout << "init half : " << float(in_init) << std::endl;

  __half* in = nullptr;
  int  * out = nullptr;

  cudaMalloc(&in, sizeof(__half));
  cudaMalloc(&out, sizeof(int));

  cudaMemcpy(in, &in_init, sizeof(__half), cudaMemcpyHostToDevice);

  test<<<1, 1>>>(in, out);

  int host_out;
  cudaMemcpy(&host_out, out, sizeof(int), cudaMemcpyDeviceToHost);

  std::cout << host_out << std::endl;
  return 0;
}
