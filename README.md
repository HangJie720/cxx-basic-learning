# ai-framework-basics

C++, CUDA, and Python side by side for learning AI framework internals, with a focus on PyTorch: tensors, autograd, modules, data loading, optimizers, CUDA extensions, and distributed training.

`cpp` and `cuda` are already here. `python` will be filled in by module so you can compare the same idea in the Python API, ATen/C++, and CUDA kernels.

## Learning path

| Module | What to clarify | Python | C++ / CUDA |
| --- | --- | --- | --- |
| Tensor | Storage, stride, dtype, device, view vs copy | `torch.Tensor` | ATen `TensorImpl` |
| Autograd | Forward recording, backward, `grad_fn`, custom `Function` | `torch.autograd` | `autograd::Function` |
| NN | `Module`, parameter registration, `forward`, functional API | `torch.nn`, `torch.nn.functional` | ATen ops |
| Optim / AMP | SGD, Adam, grad scaling, mixed precision | `torch.optim`, `torch.amp` | Matching kernels |
| Data | `Dataset`, `DataLoader`, sampling and collation | `torch.utils.data` | — |
| CUDA | Memory, streams, custom ops, library ops | `torch.cuda`, `torch.utils.cpp_extension` | Kernels and notes under `cuda/` |
| Distributed | Process groups, allreduce, collective communication | `torch.distributed` | NCCL / communication libs |
| Export | Trace, script, graph export | `torch.jit`, `torch.export` | — |

## cpp

- `Cpp-Primer`: Exercises from *C++ Primer*, submodule [Mooophy/Cpp-Primer](https://github.com/Mooophy/Cpp-Primer).
- `leetcode`: Interview-oriented C++ solutions covering arrays, strings, linked lists, stacks/queues, binary trees, binary search, DP, backtracking, and graphs (100+ problems).
- `modern-cpp-tutorial`: Modern C++ notes, examples, and drills to prepare for reading PyTorch's C++ frontend.

## cuda

- `cuda-sample`: CUDA Samples kept in-tree.
- `cuda-samples`: Official NVIDIA CUDA Samples submodule, checked out around v11.4.1.
- `cuda-10.2`, `cuda-11.4`: CUDA headers for the matching versions.
- `CUDA-Programming`, `Learn-CUDA-Programming`, `Professional-CUDA-C-Programming`, `cudahandbook`: Book companion code for threads, memory, reductions, and concurrency.
- `CUDALibrarySamples`: Examples for cuBLASLt, cuFFT, cuSOLVER, cuSPARSE, NPP, nvJPEG, and related libraries — the building blocks behind PyTorch linear algebra and signal ops.
- `DeepLearning-Training-Cuda`: cuDNN-based MNIST training sample that mirrors a CNN at the library level.

## python

Planned minimal runnable examples by PyTorch module:

- `tensor`, `autograd`, `nn`, `optim`
- `data`, `cuda`, `distributed`, `export`

Clone with submodules:

```bash
git clone --recurse-submodules git@github.com:HangJie720/ai-framework-basics.git
```
