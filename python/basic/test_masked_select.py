import torch

a = torch.randn((1,8,12,12)).cuda()
b = a.ne(0)
# print(b.cpu())
# print(b.shape)
c = torch.masked_select(a, b)
#b = a.ne(0)
#print(b.cpu())
# print(a)
