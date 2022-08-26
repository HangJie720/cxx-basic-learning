import torch
import torch.nn as nn
import numpy as np

torch.manual_seed(543)

class Policy(nn.Module):
    def __init__(self):
        super(Policy, self).__init__()
        self.affine1 = nn.Linear(4, 128)
    
    def forward(self, x):
        x = self.affine1(x)

policy = Policy()

m = nn.Dropout(p=0.5)
#x = torch.tensor([[0.2752, -0.4269, -0.0191, -0.2791,  0.4589,  0.1128,  0.1387,  0.1958,
#         -0.3916,  0.3365, -0.0383, -0.4953,  0.2386, -0.0854, -0.4910,  0.2382]]).cuda()

x = torch.tensor([[1., 2., 3., 4., 5., 6., 7., 8., 9., 10.]]).cuda()
print(x)
x = m(x)
print(x)
