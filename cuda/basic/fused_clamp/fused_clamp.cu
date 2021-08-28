#include <iostream>
#include <iomanip>
#include <cmath>
#include <string>
#include <random>

using namespace std;

extern "C" __global__
void fused_clamp(float* t0, float* aten_clamp) 
{
  if (512 * blockIdx.x + threadIdx.x<16 ? 1 : 0) {
    float t0_1 = t0[512 * blockIdx.x + threadIdx.x];
    if (!std::isnan(t0_1)) {
        aten_clamp[512 * blockIdx.x + threadIdx.x] = (t0_1<0.f ? 0.f : t0_1)>2.f ? 2.f : (t0_1<0.f ? 0.f : t0_1);
    } else {
        aten_clamp[512 * blockIdx.x + threadIdx.x] = t0_1;
    }
  }
}

#define gpuErrorCheck(ans) {gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
    if (code != cudaSuccess)
    {
        fprintf(stderr, "GPU assert: %s %s %d\n",
            cudaGetErrorString(code), file, line);
        if (abort) exit(code);
    }
}

int main()
{
    const int n = 16;
    float *h_in, *h_out_cpu, *h_out_gpu,*d_in, *d_out;

    h_in = (float*) malloc(n * sizeof(float));
    h_out_cpu = (float*) malloc(n * sizeof(float));
    h_out_gpu = (float*) malloc(n * sizeof(float));
    for (int i = 0; i < n; i++) {
        h_out_cpu[i] = 0;
        h_out_gpu[i] = 0;
    }

    printf("input is: \n");
    std::default_random_engine gen;
    std::normal_distribution<float> rand(0,1);
    for(int i = 0; i < n ; i++){
        h_in[i] = std::nan("1");  // nan result only shows up when having positive inputs and negative inputs, and range should be large enough.
        printf("%f, ",h_in[i]);
    }
    
    gpuErrorCheck(cudaMalloc((void **)&d_in, n * sizeof(float)));
    gpuErrorCheck(cudaMalloc((void **)&d_out, n * sizeof(float)));
    gpuErrorCheck(cudaMemcpy(d_in, h_in, n * sizeof(float), cudaMemcpyHostToDevice));
    gpuErrorCheck(cudaMemcpy(d_out, h_out_gpu, n * sizeof(float), cudaMemcpyHostToDevice));

    dim3 block = 512;
    dim3 grid = (n + block.x - 1) / block.x;
    fused_clamp<<<grid, block>>>(d_in, d_out);
    gpuErrorCheck(cudaDeviceSynchronize());
    gpuErrorCheck(cudaMemcpy(h_out_gpu, d_out, n * sizeof(float), cudaMemcpyDeviceToHost));

    printf("\n-------------result--------------\n");
    for (int i = 0; i < n; ++i){
        cout << "output result: " << h_out_gpu[i] << endl;
    }

    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);
    free(h_out_cpu);
    free(h_out_gpu);
    return 0;
}
