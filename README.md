# AI Framework Basics

C++、CUDA 与 Python 对照学习 AI 框架的基础代码，重点是 PyTorch 各功能模块：从张量、自动求导、网络层，到数据、优化、CUDA 扩展和分布式。

当前已有 `cpp` 与 `cuda`。`python` 按下面的模块目录补齐，用来对照同一功能在 Python API、ATen/C++ 和 CUDA kernel 里分别怎么实现。

## 学习路线

| 模块 | 要弄清的问题 | Python | C++ / CUDA |
| --- | --- | --- | --- |
| Tensor | 存储、stride、dtype、device、view 与拷贝 | `torch.Tensor` | ATen `TensorImpl` |
| Autograd | 前向记录、反向、`grad_fn`、自定义 `Function` | `torch.autograd` | `autograd::Function` |
| NN | `Module`、参数注册、`forward`、函数式 API | `torch.nn`、`torch.nn.functional` | ATen 算子 |
| Optim / AMP | SGD、Adam、梯度缩放、混合精度 | `torch.optim`、`torch.amp` | 对应 kernel |
| Data | `Dataset`、`DataLoader`、采样与拼接 | `torch.utils.data` | — |
| CUDA | 显存、stream、自定义算子、算子库 | `torch.cuda`、`torch.utils.cpp_extension` | `cuda/` 下的 kernel 与教材 |
| Distributed | 进程组、allreduce、集合通信 | `torch.distributed` | NCCL / 通信库 |
| Export | trace、script、导出计算图 | `torch.jit`、`torch.export` | — |

## cpp

- `Cpp-Primer`：《C++ Primer》练习，子模块 [Mooophy/Cpp-Primer](https://github.com/Mooophy/Cpp-Primer)。
- `leetcode`：面试题的 C++ 实现，覆盖数组、字符串、链表、栈队列、二叉树、二分、动态规划、回溯和图，共 100 余题。
- `modern-cpp-tutorial`：现代 C++ 教程、示例和练习，为阅读 PyTorch C++ 前端做准备。

## cuda

- `cuda-sample`：仓库内保存的 CUDA Samples。
- `cuda-samples`：NVIDIA 官方 CUDA Samples 子模块，检出在 v11.4.1 附近。
- `cuda-10.2`、`cuda-11.4`：对应版本的 CUDA 头文件。
- `CUDA-Programming`、`Learn-CUDA-Programming`、`Professional-CUDA-C-Programming`、`cudahandbook`：教材配套代码，对应线程、内存、归约和并发。
- `CUDALibrarySamples`：cuBLASLt、cuFFT、cuSOLVER、cuSPARSE、NPP、nvJPEG 等库示例，对应 PyTorch 里的线性代数与信号处理算子。
- `DeepLearning-Training-Cuda`：基于 cuDNN 的 MNIST 训练示例，对应卷积网络的底层实现。

## python

计划按 PyTorch 模块放置最小可运行示例：

- `tensor`、`autograd`、`nn`、`optim`
- `data`、`cuda`、`distributed`、`export`

克隆时带子模块：

```bash
git clone --recurse-submodules git@github.com:HangJie720/cxxtools.git
```
