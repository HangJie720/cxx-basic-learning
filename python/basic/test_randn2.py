import torch
import random
import numpy as np
import torch.nn as nn
def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True

set_seed(100)
device = "cuda:0"

#fixed_noise = torch.randn(64, 100, 1, 1, device=device)
#print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
#print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

weight = torch.randn(100, 512, 4, 4, device=device)
print("weight Mean): ",np.mean(weight.detach().cpu().numpy()))
print("weight Var): ", np.var(weight.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

a = torch.randn(4, device=device)
print(a.detach().cpu())
b = torch.randint(4, (2,2), device=device)
print(b.detach().cpu())
