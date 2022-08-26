import torch
import random
import numpy as np
import torch.nn as nn
def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True

set_seed(100)
device = "cuda:0"

# custom weights initialization called on netG and netD
def weights_init(m):
    classname = m.__class__.__name__
    if classname.find('Conv') != -1:
        print(m.weight.shape)
        print("Conv weight Mean): ",np.mean(m.weight.detach().cpu().numpy()))
        print("Conv weight Var): ", np.var(m.weight.detach().cpu().numpy()))
        torch.nn.init.normal_(m.weight, 0.0, 0.02)
        print(m.weight.shape)
        print("Conv weight Mean Normal): ",np.mean(m.weight.detach().cpu().numpy()))
        print("Conv weight Var Normal): ", np.var(m.weight.detach().cpu().numpy()))


class Generator(nn.Module):
    def __init__(self, ngpu):
        super(Generator, self).__init__()
        self.ngpu = ngpu
        self.main = nn.Sequential(
            #nn.ConvTranspose2d(100, 64 * 8, 4, 1, 0, bias=False),
            nn.Conv2d(512, 100, 4, 2, 1, bias=False),
        )

    def forward(self, input):
        output = self.main(input)
        return output

#netG = Generator(1).to(device)
#netG.apply(weights_init)
#weight = torch.randn(100, 512, 4, 4, device="cpu")
#print("weight Mean): ",np.mean(weight.detach().cpu().numpy()))
#print("weight Var): ", np.var(weight.detach().cpu().numpy()))
#weight.cuda()
#torch.nn.init.normal_(weight, 0.0, 0.02)
#print("weight Mean Normal): ",np.mean(weight.detach().cpu().numpy()))
#print("weight Var Normal): ", np.var(weight.detach().cpu().numpy()))

#weight = torch.randn(100, 512, 4, 4, device=device)
#print("weight Mean): ",np.mean(weight.detach().cpu().numpy()))
#print("weight Var): ", np.var(weight.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

fixed_noise = torch.randn(64, 100, 1, 1, device=device)
print("fixed_noise mean is: ", np.mean(fixed_noise.detach().cpu().numpy()))
print("fixed_noise var is: ", np.var(fixed_noise.detach().cpu().numpy()))

a = torch.randn(4, device=device)
print(a)
b = torch.randint(4, (2,2), device=device)
print(b)
