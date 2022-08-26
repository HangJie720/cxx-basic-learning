import torch
t = torch.full((1,), 255.0, dtype=torch.float32, device='cuda')
b = 255.0 / t
#print("%.9f" % b[0])
