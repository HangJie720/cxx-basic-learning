import torch
import numpy as np

input = np.random.randn(1, 8, 12, 12).astype(np.float32)
tensor_input = torch.from_numpy(input).cuda()

print(tensor_input)
