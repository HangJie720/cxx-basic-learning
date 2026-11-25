# cuDNN samples

NVIDIA cuDNN convolution samples: sweep forward algorithms (`Get` / `Find` / explicit algo),
measure workspace / timing, and check whether supported algorithms agree on the same output.

Requires: `nvcc`, CUDA toolkit, cuDNN (BF16 needs cuDNN ≥ 8), and a GPU.

| Sample | What it does | Out-of-box |
| --- | --- | --- |
| [`Conv2dAlgoRandomNCHW`](Conv2dAlgoRandomNCHW/) | Random NCHW Conv2d; optional ResNet50-like shape batch | Yes |
| [`Conv3dAlgoPrecision`](Conv3dAlgoPrecision/) | NCDHW Conv3d on user-provided golden tensors | Needs `golden/` inputs |

Common knobs: `CUDA_HOME`, `CUDNN_HOME`, `NV_GPU_ARCH` (default `sm_80`).
