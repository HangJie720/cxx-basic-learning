import torch
import torch.nn as nn
import numpy as np
import random

def setup_seed(seed):
     torch.manual_seed(seed)
     torch.cuda.manual_seed_all(seed)
     np.random.seed(seed)
     random.seed(seed)
    #  torch.backends.cudnn.deterministic = True
# 设置随机数种子
setup_seed(10038)

m = nn.GLU()
input = torch.randn(2, 4, 6).cuda()
# input = torch.randn(4, 2).cuda()
# print("input is: ", input)
output = m(input)
# torch.pow(input, input)
#print("output is: ", output)
#print("output shape is: ", output.shape)
