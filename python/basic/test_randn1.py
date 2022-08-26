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

noise = torch.randn(1, 1, 1, 1, device="cuda")
print(noise)
