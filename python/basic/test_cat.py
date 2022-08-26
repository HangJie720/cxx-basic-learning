import torch

def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

set_seed(22)

a = torch.Tensor([[0., 0., 0., 0., 0., 0., 0., 0., 0., 0.]]).to("cuda:1")
b = torch.Tensor([[5.9761, 1.2968, 6.2350, 2.7962, 1.0721, 4.2223, 2.9957, 9.3396, 4.5180,
    4.0921]]).to("cuda:1")
norm_buf = torch.cat([a, b], 0)
print(norm_buf)

a = torch.Tensor([[0., 0., 0., 0., 0., 0., 0., 0., 0., 0.]]).to("cuda:0")
b = torch.Tensor([[5.9761, 1.2968, 6.2350, 2.7962, 1.0721, 4.2223, 2.9957, 9.3396, 4.5180,
    4.0921]]).to("cuda:0")
norm_buf = torch.cat([a, b], 0)
print(norm_buf)
