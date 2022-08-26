import torch

def setup_seed(seed):
     torch.manual_seed(seed)
     torch.cuda.manual_seed_all(seed)
setup_seed(20)


a = torch.geqrf(torch.randn([4,4], dtype=torch.float).cuda())
print(a)
