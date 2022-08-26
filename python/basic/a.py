import torch
x = torch.randn(1,2).cuda()
print(x)
#y = x.clone().detach()
#torch.set_printoptions(2)
#torch.set_default_tensor_type(torch.cuda.FloatTensor)
y = 2 * x.double()
print(y)
