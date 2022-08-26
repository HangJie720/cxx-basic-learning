import torch
import numpy as np
import random

def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

torch._C._jit_set_nvfuser_enabled(True)

old_guard = torch._C._jit_set_nvfuser_guard_mode(True)
torch._C._jit_set_bailout_depth(20)
torch._C._jit_set_texpr_fuser_enabled(False)
torch._C._jit_set_profiling_executor(True)
torch._C._jit_set_profiling_mode(True)

def t(scale: float, x: torch.Tensor, y: torch.Tensor, z: torch.Tensor):
    o = torch.mul(x, y)
    o = torch.mul(o, scale)
    out1 = torch.mul(o, z)
    out2 = torch.sum(out1, dim=[2])
    return out1, out2

x = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
y = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
z = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
print("x mean: ", torch.mean(x.detach().cpu()))
print("x var: ", torch.var(x.detach().cpu()))
print("y mean: ", torch.mean(y.detach().cpu()))
print("y var: ", torch.var(y.detach().cpu()))
print("z mean: ", torch.mean(z.detach().cpu()))
print("z var: ", torch.var(z.detach().cpu()))
scale = 0.5

t_jit = torch.jit.script(t)
jit_o = t_jit(scale, x, y, z)
jit_o = t_jit(scale, x, y, z)
print("jit_o[0] mean: ", torch.mean(jit_o[0].detach().cpu()))
print("jit_o[0] var: ", torch.var(jit_o[0].detach().cpu()))

print("jit_o[1] mean: ", torch.mean(jit_o[1].detach().cpu()))
print("jit_o[1] var: ", torch.var(jit_o[1].detach().cpu()))

o = t(scale, x, y, z)
print("o[0] mean: ", torch.mean(o[0].detach().cpu()))
print("o[0] var: ", torch.var(o[0].detach().cpu()))

print("o[1] mean: ", torch.mean(o[1].detach().cpu()))
print("o[1] var: ", torch.var(o[1].detach().cpu()))
torch._C._jit_set_nvfuser_guard_mode(old_guard)
