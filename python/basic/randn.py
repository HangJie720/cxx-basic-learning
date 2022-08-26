import torch
import random
import numpy as np
#def set_seed(seed):
#    torch.manual_seed(seed)
#    torch.cuda.manual_seed(seed)
#    torch.cuda.manual_seed_all(seed)
#set_seed(100)
noise = torch.randn(32, 28, 28, 3, device='cuda:0')
#print(a)
