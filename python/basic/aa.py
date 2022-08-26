import torch

a  = torch.FloatTensor([[0, 1, 2], [3, 4, 5]])
b  = torch.FloatTensor([[0, 1], [2, 3], [4, 5]])

a1 =  a.to("cuda:0")
b1 =  b.to("cuda:0")

a2 =  a.to("cuda:1")
b2 =  b.to("cuda:1")

#test1
c1 = torch.mm(a1, b1).to("cpu")
c2 = torch.mm(a2, b2).to("cpu")
d = c1 + c2
print(d)
