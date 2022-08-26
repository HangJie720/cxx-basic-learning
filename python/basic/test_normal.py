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
torch.set_printoptions(precision=16)
for i in range(2):
    print('---------------------------------------------------', i)
    w = torch.empty(100, 512, 4, 4, device='cuda:0')
    # w = torch.empty(100, 512, 4, 4, device='cpu')
    torch.nn.init.normal_(w, 0.0, 0.2)
    #print(w)
    #print(w.dtype)
    #print(w.mean())
    #print(w.std())
