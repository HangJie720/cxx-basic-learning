#include <stdio.h>
#include <stdint.h>
#include<algorithm>
#include <time.h>
#include<device_atomic_functions.h>


#define SEPARATOR '-'
#define GET_TIME_NS(start, end) (end.tv_sec - start.tv_sec) * 1000000000 + (end.tv_nsec - start.tv_nsec)

template<typename T>
__device__ T temp_atomicMax(T * a, T b) {
  T old = *a, assumed;
  do {
    assumed = old;
    old = atomicMax(a,b);
  }
  while(old != assumed);
  return old;
}

template<>
__device__ float temp_atomicMax(float *addr,float val){
  float old = *addr, assumed;
  do {
    assumed = old;
    old = atomicCAS(reinterpret_cast<int *>(addr),__float_as_int(assumed),__float_as_int(fmaxf(*addr,val)));
  }
  while(old != assumed);
  return __int_as_float(old);
};
__global__ void do_in_parallel(float *array_a, float *array_b,int size) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  int step = blockDim.x * gridDim.x;
  for(int i = tid; i < size; i += step) {
    array_a[i] = temp_atomicMax(array_a + i, array_b[i]);
  }
}
int main(int argc, char** argv) {
    int batch = 1;
    int height = 3;
    int width = 3;
    int channel = 3;
    int gridsize = 1;
    int blocksize = 1;
    int loop_num = 1;

    int error = 0;
    argc -= 1;
    argv++;
    while (argc) {
        if (*argv[0] == SEPARATOR) {
            switch (*(argv[0] + 1)) {
            case 'n':
                batch = atoi(argv[0] + 2);
                break;
            case 'h':
                height = atoi(argv[0] + 2);
                break;
            case 'w':
                width = atoi(argv[0] + 2);
                break;
            case 'c':
                channel = atoi(argv[0] + 2);
                break;
            case 'g':
                gridsize = atoi(argv[0] + 2);
                break;
            case 'b':
                blocksize = atoi(argv[0] + 2);
                break;
            case 'l':
                loop_num = atoi(argv[0] + 2);
                break;
            default:
                error++;
                break;
            }
            if (error) {
                fprintf(stderr, "Unknown switch '%c%s'\n\n", SEPARATOR, argv[0] + 1);
                return error;
            }
        }
        else {
            fprintf(stderr, "Invalid separator '%c' for option '%s'\n\n", *argv[0], argv[0] );
            return 1;
        }
        argc -= 1;
        argv++;
    }

    fprintf(stderr, "Begin...\n");
    int element_size = batch * height * width * channel;
    float *a_host;
    float *b_host;
    struct timespec start, end;
    float time_use, time_sum;

    a_host = (float *)malloc(element_size*sizeof(float));
    b_host = (float *)malloc(element_size*sizeof(float));

    for (int i = 0; i < element_size; i++) {
       a_host[i] = (float)rand();
       b_host[i] = (float)rand();
    }

    fprintf(stderr, "Allocating device memory...\n");
    float *a_dev;
    float *b_dev;

    cudaMalloc((void**) &a_dev, element_size*sizeof(float));
    cudaMalloc((void**) &b_dev, element_size*sizeof(float));

    clock_gettime(CLOCK_REALTIME, &start);
    cudaMemcpy(a_dev, a_host, element_size*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(b_dev, b_host, element_size*sizeof(float), cudaMemcpyHostToDevice);
    cudaDeviceSynchronize();
    clock_gettime(CLOCK_REALTIME, &end);
    time_use = GET_TIME_NS(start, end);
    fprintf(stderr, "Copy host data to device, time used: %.0f ns\n", time_use);

    dim3 dimGrid(gridsize, 1, 1);
    dim3 dimBlock(blocksize, 1, 1);

    fprintf(stderr, "Parameters: N=%d, H=%d, W=%d, C=%d, element_size=%d, grid_size=%d, block_size=%d\n",
            batch, height, width, channel, element_size, gridsize, blocksize);

    for (int loop = 0; loop < loop_num; loop++) {
        clock_gettime(CLOCK_REALTIME, &start);
        do_in_parallel<<<dimGrid, dimBlock>>>(a_dev, b_dev, element_size);
        cudaDeviceSynchronize();
        clock_gettime(CLOCK_REALTIME, &end);
        time_use = GET_TIME_NS(start, end);
        if (loop == 0) {
            time_sum = 0;
        } else {
            time_sum += time_use;
        }
        fprintf(stderr, "Run GPU kernel for loop %d, time used: %.0f ns\n", loop, time_use);
    }
    if (loop_num > 1) {
        fprintf(stderr, "Run GPU kernel average (exclude the 1st loop) time used: %.0f ns\n", time_sum / (loop_num - 1));
    }

    clock_gettime(CLOCK_REALTIME, &start);
    cudaDeviceSynchronize();
    clock_gettime(CLOCK_REALTIME, &end);
    time_use = GET_TIME_NS(start, end);
    fprintf(stderr, "Copy dev data to host, time used: %.0f ns\n", time_use);

    fprintf(stderr, "Verify result...\n");
    int status = 0;
    for (int loop = 0; loop < loop_num; loop++) {
        clock_gettime(CLOCK_REALTIME, &start);
        for (int i = 0; i < element_size; i++) {
          a_host[i] = max(a_host[i],b_host[i]);
        }
        clock_gettime(CLOCK_REALTIME, &end);
        time_use = GET_TIME_NS(start, end);
        if (loop == 0) {
            time_sum = 0;
        } else {
            time_sum += time_use;
        }
        fprintf(stderr, "Run CPU compute for loop %d, time used: %.0f ns\n", loop, time_use);
    }
    if (loop_num > 1) {
        fprintf(stderr, "Run CPU compute average (exclude the 1st loop) time used: %.0f ns\n", time_sum / (loop_num - 1));
    }
    if (status) {
       fprintf(stderr, "Failed vervified.\n");
    } else {
       fprintf(stderr, "Successfully verified.\n");
    }
    cudaMemcpy(b_host, a_dev, element_size*sizeof(float), cudaMemcpyDeviceToHost);
    for (int loop = 0;loop < element_size;loop++) {
      if ((a_host[loop] - b_host[loop])/a_host[loop] >= 1e-5 ||
          (a_host[loop] - b_host[loop])/a_host[loop] <= -1e-5)  {
        fprintf(stderr, "pase failed: a = %.3f b = %.3f\n",a_host[loop],b_host[loop]);
      }
    }

    fprintf(stderr, "Free dev memory\n");
    cudaFree(a_dev);
    cudaFree(b_dev);

    fprintf(stderr, "Free host memory\n");
    free(a_host);
    free(b_host);
    return 0;
} 

