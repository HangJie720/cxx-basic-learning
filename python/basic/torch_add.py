import torch
a = torch.randn(4)
print("a= ", a)
print("cpu= ", torch.add(a, 20))
print("gpu= ", torch.add(a, 20).cuda())
#print("gpu= ", torch.add(a.cuda(), 20))
