import torch

x = torch.arange(1, 3, dtype=torch.float, device='cuda')
#print(x)
x = x.to(torch.float16)
#print(x)
fn = lambda x: torch.remainder(x, 1.5)
ref = fn(x)
#print(ref)
