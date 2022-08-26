import torch
inputx = torch.randint(0, 8, (5, )).cuda()
print(inputx)
a = torch.bincount(inputx)
print(a)
