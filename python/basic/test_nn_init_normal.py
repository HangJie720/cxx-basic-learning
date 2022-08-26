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

a = torch.randn(torch.Size([100, 512, 4, 4])).cuda()
print(np.mean(a.detach().cpu().numpy()))
print(np.var(a.detach().cpu().numpy()))
a.normal_(0.0, 1.0)
print(np.mean(a.detach().cpu().numpy()))
print(np.var(a.detach().cpu().numpy()))

b = torch.randn(torch.Size([100, 512, 4, 4])).cuda()
print(np.mean(b.detach().cpu().numpy()))
print(np.var(b.detach().cpu().numpy()))


c = torch.randn(torch.Size([100, 512, 4, 4])).cuda()
print(np.mean(c.detach().cpu().numpy()))
print(np.var(c.detach().cpu().numpy()))
