import torch

tensor1 = torch.randn(5, 2, 1, 3, device="cuda")[:, 0]
tensor2 = torch.randn(5, 2, 1, 3, device="cuda")[:, 0]
res = torch._foreach_add([tensor1], [tensor2])
