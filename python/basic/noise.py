import torch
import numpy as np
import random

def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True


set_seed(100)

noise = torch.randn(64, 100, 3, 3, device='cuda')
#noise = torch.randn(1, 2, 2, 1, device='cuda')
print(noise)
print(np.mean(noise.cpu().detach().numpy()))
print(np.var(noise.cpu().detach().numpy()))
np.save("a.npy", noise.cpu().detach().numpy())
