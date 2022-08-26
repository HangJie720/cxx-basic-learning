import torch
import random
import numpy as np
def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

batch_size=64
nz=100
device="cuda"
noise = torch.randn(batch_size, nz, 1, 1, device=device)
print("noise dtype: ",noise.dtype)
print("noise shape: ", noise.shape)
print("noise mean: ", np.mean(noise.detach().cpu().numpy()))
print("noise var: ", np.var(noise.detach().cpu().numpy()))
