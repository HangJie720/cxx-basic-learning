import torch
import torch.nn as nn
import numpy as np

torch.manual_seed(543)

m = nn.Dropout(p=0.6)
input = torch.randn(1, 128).cuda()
print(input.shape)
print(input.detach().cpu())
print(np.mean(input.detach().cpu().numpy()), np.var(input.detach().cpu().numpy()))
output = m(input)
print(output.detach().cpu())
print(np.mean(output.detach().cpu().numpy()), np.var(output.detach().cpu().numpy()))
