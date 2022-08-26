
import torch

import torch.nn.functional as F

x = torch.ones(4,3,8,8).cuda()

y = F.unfold(x, (3, 3))

print(y.sum())
