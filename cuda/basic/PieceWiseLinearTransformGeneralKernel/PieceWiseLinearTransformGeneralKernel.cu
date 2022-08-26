#include <thrust/binary_search.h>
#include <thrust/device_vector.h>
#include <thrust/execution_policy.h>
#include <thrust/functional.h>
//#include <thrust/system/cuda/execution_policy.h>

#define CUDA_1D_KERNEL_LOOP(i, n)                                 \
  for (size_t i = blockIdx.x * blockDim.x + threadIdx.x; i < (n); \
       i += blockDim.x * gridDim.x)

__global__ void PieceWiseLinearTransformGeneralKernel(
    const int N,
    const int M,
    const int num_grp,
    const int num_fnc_per_grp,
    const float* bounds,
    const float* slopes,
    const float* intercepts,
    const float* X,
    float* Y) {
  CUDA_1D_KERNEL_LOOP(i, N * M) {
    int col = i % M;
    const float* bounds_group = bounds + (col * (num_fnc_per_grp + 1));
    const float* slopes_group = slopes + (col * num_fnc_per_grp);
    const float* intercepts_group = intercepts + (col * num_fnc_per_grp);

    if (X[i] <= bounds_group[0]) {
      Y[i] = slopes_group[0] * bounds_group[0] + intercepts_group[0];
    } else if (X[i] >= bounds_group[num_fnc_per_grp]) {
      Y[i] = slopes_group[num_fnc_per_grp - 1] * bounds_group[num_fnc_per_grp] +
          intercepts_group[num_fnc_per_grp - 1];
    } else {
      auto low_bound = thrust::lower_bound(
          thrust::host,
          bounds_group,
          bounds_group + num_fnc_per_grp + 1,
          X[i]);
      int bounds_idx = low_bound - bounds_group - 1;
      Y[i] = slopes_group[bounds_idx] * X[i] + intercepts_group[bounds_idx];
    }
  }
}

int main(int argc, char* argv[]){
    return 0;
}
