import torch
import numpy as np
import random

def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

noise = torch.randn(1, 3, 1, 1, device='cpu')
print(noise)
print(np.mean(noise.numpy()))
print(np.std(noise.numpy()))
value = torch.std(noise.cuda())
print(value)
