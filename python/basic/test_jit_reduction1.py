import torch

torch._C._jit_set_nvfuser_enabled(True)
torch._C._jit_set_texpr_fuser_enabled(False)


def reduction_helper(x, y):
    o = torch.add(x, y)
    o = torch.sum(o, dim=(0,1))
    return o


t_jit = torch.jit.script(reduction_helper)

x = torch.ones((128, 16,8,8), dtype=torch.float32, device="cuda")
y = torch.ones((128, 16,8,8), dtype= torch.float32, device="cuda")

jit_o = t_jit( x, y)
print(jit_o.shape)
jit_o = t_jit( x, y)
print(jit_o)
