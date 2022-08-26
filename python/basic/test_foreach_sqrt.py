import torch
import numpy as np
import random

def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

exp_avg_sq = []
a = torch.abs(torch.randint(4, 5, (1,10)).float())
#b = torch.abs(torch.randn(1))
#a = torch.randint(3, 5, (1,)).float()
print(a)
exp_avg_sq.append(a.cuda())
#exp_avg_sq.append(b.cuda())
#print("exp_avg_sq: ", exp_avg_sq)

exp_avg_sq_sqrt = torch._foreach_sqrt(exp_avg_sq)
print("exp_avg_sq_sqrt: ", exp_avg_sq_sqrt[0].detach().cpu())
#print("exp_avg_sq_sqrt[0] mean: ", torch.mean(exp_avg_sq_sqrt[0].detach().cpu()))
#print("exp_avg_sq_sqrt[0] var: ", torch.var(exp_avg_sq_sqrt[0].detach().cpu()))
#print("exp_avg_sq_sqrt[1] mean: ", torch.mean(exp_avg_sq_sqrt[1].detach().cpu()))
#print("exp_avg_sq_sqrt[1] var: ", torch.var(exp_avg_sq_sqrt[1].detach().cpu()))
