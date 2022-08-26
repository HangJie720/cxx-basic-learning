from torch.distributions.poisson import Poisson
import torch

def setup_seed(seed):
     torch.manual_seed(seed)
     torch.cuda.manual_seed_all(seed)
     torch.backends.cudnn.deterministic = True
setup_seed(20)

m = Poisson(torch.tensor([4.]).cuda())
print(m.sample())
