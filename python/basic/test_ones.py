import torch
p=torch.ones(1,3,190,384,384).float().cuda()
x=p.as_strided((1,3,190,384,384),(84049920,1,442368,1152,3)) # x stride is (84049920, 1, 442368, 1152, 3)
a = torch.sum(x, [2,3,4])
print(a)
