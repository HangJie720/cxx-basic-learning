#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(int n, float a, float *x, float *y)
{
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  if (i < n)
    y[i] = a*x[i] + y[i];
}

int main(void)
{
  int N = 1<<10;
  float *x, *y, *d_x, *d_y;
  x = (float*)malloc(N*sizeof(float));
  y = (float*)malloc(N*sizeof(float));

  cudaMalloc(&d_x, N*sizeof(float)); 
  cudaMalloc(&d_y, N*sizeof(float));

  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+255)/256, 256>>>(N, 2.0f, d_x, d_y);

  cudaMemcpy(y, d_y, N*sizeof(float), cudaMemcpyDeviceToHost);

  float maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++)
    maxError = max(maxError, abs(y[i]-4.0f));
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}



/*

#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(double *x, double *y)
{
  int i = threadIdx.x;
    y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 64;
  double *x, *y, *d_x, *d_y;
  x = (double*)malloc(N*sizeof(double));
  y = (double*)malloc(N*sizeof(double));

  cudaMalloc(&d_x, N*sizeof(double)); 
  cudaMalloc(&d_y, N*sizeof(double));

  for (int i = 0; i < N; i++) {
    x[i] = 2.0f;
    y[i] = 2.0f;
  }
printf("re: %lf\n", y[0]);
  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+63)/64, 64>>>(d_x, d_y);

  cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);
printf("re1: %lf\n", y[0]);
  double maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++) {
    maxError = max(maxError, abs(y[i]-4.0f));
	  printf("re: %lf\n", y[i]);
  }
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}



#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(double *x, double *y)
{
  int i = threadIdx.x;
    y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 64;
  double *x, *y, *d_x, *d_y;
  x = (double*)malloc(N*sizeof(double));
  y = (double*)malloc(N*sizeof(double));

  cudaMalloc(&d_x, N*sizeof(double)); 
  cudaMalloc(&d_y, N*sizeof(double));

  for (int i = 0; i < N; i++) {
    x[i] = 2.0f;
    y[i] = 2.0f;
  }

  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+63)/64, 64>>>(d_x, d_y);

  cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);

  double maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++) {
    maxError = max(maxError, abs(y[i]-4.0f));
  }
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}
























#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(int n, double a, double *x, double *y)
{
  int i = threadIdx.x;
    y[i] = a*x[i] + y[i];
}

int main(void)
{
  int N = 64;
  double *x, *y, *d_x, *d_y;
  x = (double*)malloc(N*sizeof(double));
  y = (double*)malloc(N*sizeof(double));

  cudaMalloc(&d_x, N*sizeof(double)); 
  cudaMalloc(&d_y, N*sizeof(double));

  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+63)/64, 64>>>(N, 2.0f, d_x, d_y);

  cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);

  double maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++)
    maxError = max(maxError, abs(y[i]-4.0f));
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}

*/


/*//编译Pass，但是没验证正确性

#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(double *x, double *y)
{
  int i = threadIdx.x;
    y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 64;
  double *x, *y, *d_x, *d_y;
  x = (double*)malloc(N*sizeof(double));
  y = (double*)malloc(N*sizeof(double));

  cudaMalloc(&d_x, N*sizeof(double)); 
  cudaMalloc(&d_y, N*sizeof(double));

  for (int i = 0; i < N; i++) {
    x[i] = 2.0f;
    y[i] = 2.0f;
  }

  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+63)/64, 64>>>(d_x, d_y);

  cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);

  double maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++) {
    maxError = max(maxError, abs(y[i]-4.0f));
  }
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}

















#include <algorithm>
#include <stdio.h>

using namespace std;

__global__
void saxpy(double *y)
{
  int i = threadIdx.x;
    y[i] = y[i]+2.0;
}

int main(void)
{
  int N = 64;
  double *x, *y, *d_x, *d_y;
  x = (double*)malloc(N*sizeof(double));
  y = (double*)malloc(N*sizeof(double));

  cudaMalloc(&d_x, N*sizeof(double)); 
  cudaMalloc(&d_y, N*sizeof(double));

  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  cudaMemcpy(d_x, x, N*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(d_y, y, N*sizeof(double), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  saxpy<<<(N+63)/64, 64>>>(d_x);

  cudaMemcpy(y, d_y, N*sizeof(double), cudaMemcpyDeviceToHost);

  double maxError = 0.0f;
  int result = 0;
  for (int i = 0; i < N; i++)
    maxError = max(maxError, abs(y[i]-4.0f));
  printf("Max error: %f\n", maxError);
  if(maxError < 1e-5){
    printf("SUCCESS\n");
  }
  else{
    result = 1;
    printf("FAILURE\n");
  }

  cudaFree(d_x);
  cudaFree(d_y);
  free(x);
  free(y);
  return result;
}


*/
