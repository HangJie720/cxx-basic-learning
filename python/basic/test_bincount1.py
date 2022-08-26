import torch
res = torch.bincount(torch.tensor([], device="cuda", dtype=torch.long))
