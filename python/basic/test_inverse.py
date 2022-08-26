import torch

def setup_seed(seed):
     torch.manual_seed(seed)
     torch.cuda.manual_seed_all(seed)
setup_seed(20)

A = torch.tensor([[6.80, -2.11,  5.66,  5.97,  8.23],
                   [-6.05, -3.30,  5.36, -4.44,  1.08],
                   [-0.45,  2.58, -2.70,  0.27,  9.04],
                   [8.32,  2.71,  4.35,  -7.17,  2.14],
                   [-9.67, -5.14, -7.26,  6.08, -6.87]]).t().cuda()
B = torch.inverse(A)
# print(s)
#print(u)
#print(v)
