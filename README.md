# cxxtools

C++ 与 CUDA 学习代码。仓库只保留 `cpp` 和 `cuda`。

## cpp

- `Cpp-Primer`：《C++ Primer》练习，子模块 [Mooophy/Cpp-Primer](https://github.com/Mooophy/Cpp-Primer)。
- `leetcode`：常见面试题的 C++ 实现，覆盖数组、字符串、链表、栈/队列、二叉树、二分、动态规划、回溯、图、堆/单调栈等，共 100+ 题。
- `modern-cpp-tutorial`：现代 C++ 教程正文、示例和练习。

## cuda

- `basic`：短例子，包括 `atomicAdd`、`atomicCAS`、`warpSize`、`saxpy`、`thrust`、`half`、pinned memory。
- `cuda-sample`：随仓库保存的 CUDA Samples。
- `cuda-samples`：NVIDIA 官方 CUDA Samples 子模块，当前检出 v11.4.1 附近。
- `cuda-10.2`、`cuda-11.4`：对应版本的 CUDA 头文件。
- `CUDA-Programming`、`Learn-CUDA-Programming`、`Professional-CUDA-C-Programming`、`cudahandbook`：教材配套代码。
- `CUDALibrarySamples`：cuBLASLt、cuFFT、cuSOLVER、cuSPARSE、NPP、nvJPEG 等库示例。
- `DeepLearning-Training-Cuda`：基于 cuDNN 的 MNIST 训练示例。

克隆时带子模块：

```bash
git clone --recurse-submodules git@github.com:HangJie720/cxxtools.git
```
