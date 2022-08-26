import torch
import numpy as np
import random
def set_seed(seed):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
set_seed(100)

old_guard = torch._C._jit_set_nvfuser_guard_mode(True)
torch._C._jit_set_bailout_depth(20)

torch._C._jit_set_texpr_fuser_enabled(False)
torch._C._jit_set_profiling_executor(True)
torch._C._jit_set_profiling_mode(True)

def t(x: torch.Tensor, y: torch.Tensor, scale: float, z: torch.Tensor):
    o = torch.mul(x, y)
    o = torch.mul(o, scale)
    out1 = torch.mul(o, z)
    out2 = torch.sum(out1, dim=[2])
    return out1, out2

t_jit = torch.jit.script(t)
x = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
y = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
z = torch.randn(8, 4, 10, 16, dtype=torch.float, device="cuda")
scale = 0.5
jit_o = t_jit(x, y, scale, z)
print(np.mean(jit_o[0].detach().cpu().numpy()))
print(np.var(jit_o[0].detach().cpu().numpy()))
print(np.mean(jit_o[1].detach().cpu().numpy()))
print(np.var(jit_o[1].detach().cpu().numpy()))
jit_o = t_jit(x, y, scale, z)
print(np.mean(jit_o[0].detach().cpu().numpy()))
print(np.var(jit_o[0].detach().cpu().numpy()))
print(np.mean(jit_o[1].detach().cpu().numpy()))
print(np.var(jit_o[1].detach().cpu().numpy()))
o = t(x, y, scale, z)
print(np.mean(o[0].detach().cpu().numpy()))
print(np.var(o[0].detach().cpu().numpy()))
print(np.mean(o[1].detach().cpu().numpy()))
print(np.var(o[1].detach().cpu().numpy()))
torch._C._jit_set_nvfuser_guard_mode(old_guard)
