#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include <iostream>
#include <vector>
using namespace std;

#define CheckCuda(x) {\
	if(x != cudaSuccess) \
		cerr << "[CUDA Error][" << __FILE__ << " Line " << __LINE__ << "]\n\t[" \
			<< cudaGetErrorName(x) << "] " \
			<< cudaGetErrorString(x) << endl; \
}


class LoopLock{
private:
	using LockType = int32_t;

public:
	class GPUVer {
	public:
		GPUVer(LockType* d_lock): d_lock(d_lock) {}

		template<typename T_Func>
		__device__ void WithLock(T_Func func) {
			do {
				if (atomicCAS(d_lock, 1, 0) == 1) {
					func();
					*d_lock = 1;
					break;
				}
			} while (true);
		}

	private:
		LockType* d_lock;
	};

public:
	cudaError_t Alloc() {
		cudaError_t et;

		if ((et = cudaMalloc(reinterpret_cast<void**>(&d_lock), sizeof(LockType))) != cudaSuccess)
			return et;
		LockType lock = 1;
		if ((et = cudaMemcpy(d_lock, &lock, sizeof(LockType), cudaMemcpyHostToDevice)) != cudaSuccess)
			return et;

		if ((et = cudaMalloc(reinterpret_cast<void**>(&d_gpuVer), sizeof(GPUVer))) != cudaSuccess)
			return et;
		GPUVer gpuVer(d_lock);
		if ((et = cudaMemcpy(d_gpuVer, &gpuVer, sizeof(GPUVer), cudaMemcpyHostToDevice)) != cudaSuccess)
			return et;

		return et;
	}
	cudaError_t Free() {
		cudaError_t et;
		if ((et = cudaFree(d_lock)) != cudaSuccess)
			return et;
		d_lock = nullptr;
		if ((et = cudaFree(d_gpuVer)) != cudaSuccess)
			return et;
		d_gpuVer = nullptr;
		return et;
	}

private:
	// 1: not locked
	// 0: locked
	LockType* d_lock = nullptr;

public:
	GPUVer* GetGPUVer() {
		return d_gpuVer;
	}

private:
	GPUVer* d_gpuVer = nullptr;
};


__device__ void device_TestFunc(uint32_t ti, size_t* value) {
	printf("Thread %i entered with value %i\n", (int32_t)ti, (int32_t)*value);
	*value = *value + 1;
	printf("Thread %i exited with value %i\n", (int32_t)ti, (int32_t)*value);
}
static constexpr size_t N = 5;


// =====================================================
//	Origin
// =====================================================
__global__ void kernel__Test_origin(size_t n, size_t* value) {
	auto ti = blockDim.x * blockIdx.x + threadIdx.x;
	if (ti >= n)
		return;
	device_TestFunc(ti, value);
}

void Test_origin() {
	size_t* d_value;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_value), sizeof(size_t)));
	size_t value = 0;
	CheckCuda(cudaMemcpy(d_value, &value, sizeof(size_t), cudaMemcpyHostToDevice));

	kernel__Test_origin<<<1, N>>>(N, d_value);
	CheckCuda(cudaDeviceSynchronize());

	CheckCuda(cudaFree(d_value));
}




// =====================================================
//	LoopLock Class
// =====================================================
__global__ void kernel__Test_LoopLock_Class(size_t n, size_t* value, LoopLock::GPUVer* lock) {
	auto ti = blockDim.x * blockIdx.x + threadIdx.x;
	if (ti >= n)
		return;
	lock->WithLock(
		[&]() {
			device_TestFunc(ti, value);
		}
	);
}

void Test_LoopLock_Class() {
	LoopLock lock;
	CheckCuda(lock.Alloc());

	size_t* d_value;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_value), sizeof(size_t)));
	size_t value = 0;
	CheckCuda(cudaMemcpy(d_value, &value, sizeof(size_t), cudaMemcpyHostToDevice));

	kernel__Test_LoopLock_Class<<<1, N>>>(N, d_value, lock.GetGPUVer());
	CheckCuda(cudaDeviceSynchronize());

	CheckCuda(cudaFree(d_value));
	CheckCuda(lock.Free());
}






// =====================================================
//	LoopLock
// =====================================================
__global__ void kernel__Test_LoopLock(size_t n, size_t* value, int32_t* lock) {
	auto ti = blockDim.x * blockIdx.x + threadIdx.x;
	if (ti >= n)
		return;
	// Loop for introducing control divergence
	while(true) {
		// Try - Lock
		if(atomicExch(lock, 0) != 0) {
			// Work
			device_TestFunc(ti, value);
			// Unlock
			*lock = 1;
			break;
		}
	}
}

void Test_LoopLock() {
	int32_t* d_lock;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_lock), sizeof(int32_t)));
	int32_t lock = 1;
	CheckCuda(cudaMemcpy(d_lock, &lock, sizeof(int32_t), cudaMemcpyHostToDevice));

	size_t* d_value;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_value), sizeof(size_t)));
	size_t value = 0;
	CheckCuda(cudaMemcpy(d_value, &value, sizeof(size_t), cudaMemcpyHostToDevice));

	kernel__Test_LoopLock<<<1, N>>>(N, d_value, d_lock);
	CheckCuda(cudaDeviceSynchronize());

	CheckCuda(cudaFree(d_value));
	CheckCuda(cudaFree(d_lock));
}





// =====================================================
//	TicketLock
// =====================================================
__global__ void kernel__Test_TicketLock(size_t n, size_t* value, int32_t* lock) {
	auto ti = blockDim.x * blockIdx.x + threadIdx.x;
	if (ti >= n)
		return;
	for (int i = 0; i < 32; i++) {
		if (ti % 32 != i)
			continue;

		while (atomicExch(lock, 0) == 0)
			;
		device_TestFunc(ti, value);
		*lock = 1;
	}
}

void Test_TicketLock() {
	int32_t* d_lock;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_lock), sizeof(int32_t)));
	int32_t lock = 1;
	CheckCuda(cudaMemcpy(d_lock, &lock, sizeof(int32_t), cudaMemcpyHostToDevice));

	size_t* d_value;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_value), sizeof(size_t)));
	size_t value = 0;
	CheckCuda(cudaMemcpy(d_value, &value, sizeof(size_t), cudaMemcpyHostToDevice));

	kernel__Test_TicketLock<<<1, N>>>(N, d_value, d_lock);
	CheckCuda(cudaDeviceSynchronize());

	CheckCuda(cudaFree(d_value));
	CheckCuda(cudaFree(d_lock));
}




// =====================================================
//	SpinLock
// =====================================================
__global__ void kernel__Test_SpinLock(size_t n, size_t* value, int32_t* lock) {
	auto ti = blockDim.x * blockIdx.x + threadIdx.x;
	if (ti >= n)
		return;
	while (atomicExch(lock, 0) == 0)
		;
	device_TestFunc(ti, value);
	*lock = 1;
}

void Test_SpinLock() {
	int32_t* d_lock;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_lock), sizeof(int32_t)));
	int32_t lock = 1;
	CheckCuda(cudaMemcpy(d_lock, &lock, sizeof(int32_t), cudaMemcpyHostToDevice));

	size_t* d_value;
	CheckCuda(cudaMalloc(reinterpret_cast<void**>(&d_value), sizeof(size_t)));
	size_t value = 0;
	CheckCuda(cudaMemcpy(d_value, &value, sizeof(size_t), cudaMemcpyHostToDevice));

	kernel__Test_SpinLock<<<1, N>>>(N, d_value, d_lock);
	CheckCuda(cudaDeviceSynchronize());

	CheckCuda(cudaFree(d_value));
	CheckCuda(cudaFree(d_lock));
}

int main()
{
	cout << "---- Test Origin ----\n";
	Test_origin();
	cout << "\n";

	cout << "---- Test LoopLock Class ----\n";
	Test_LoopLock_Class();
	cout << "\n";

	cout << "---- Test LoopLock ----\n";
	Test_LoopLock();
	cout << "\n";

	cout << "---- Test TicketLock ----\n";
	Test_TicketLock();
	cout << "\n";

	cout << "---- Test SpinLock ----\n";
	Test_SpinLock();
	cout << "\n";
	return 0;
}