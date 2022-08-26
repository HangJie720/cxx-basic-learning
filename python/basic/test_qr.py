import torch

def setup_seed(seed):
     torch.manual_seed(seed)
     torch.cuda.manual_seed_all(seed)
setup_seed(20)

A = torch.tensor([[12., -51, 4], [6, 167, -68], [-4, 24, -41]]).cuda()
Q, R = torch.linalg.qr(A)
# print(Q)
# print(R)

# a = torch.qr(torch.zeros([4,4], dtype=torch.float).cuda())
# print(a)
