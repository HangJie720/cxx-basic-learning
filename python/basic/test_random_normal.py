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
a = torch.Size([1,2])
print(a)
value = np.random.normal(0.0, 0.02, size=torch.Size([1,2]))
print(value)










