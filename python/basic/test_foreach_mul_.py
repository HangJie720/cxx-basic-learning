import torch
import numpy as np
exp_avg = []
a = torch.from_numpy(np.array([[0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.],
        [0., 0., 0., 0., 0.]])).to(torch.float32).cuda()
b = torch.from_numpy(np.array([0., 0., 0., 0., 0., 0., 0., 0., 0., 0.])).to(torch.float32).cuda()
exp_avg.append(a)
exp_avg.append(b)
exp_avg.append(b)
beta = 0.9
#print(exp_avg)
torch._foreach_mul_(exp_avg, beta)
print(exp_avg)
