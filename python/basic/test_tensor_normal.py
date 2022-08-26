import torch
a = torch.randn(3)
print(a)
a.normal_(0.0, 0.2)
print(a)
