import torch
import random
import numpy as np
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

def t(x: torch.Tensor, y: torch.Tensor, scale: float):
    o = torch.mul(x, y)
    o = torch.mul(o, scale)
    return o

t_jit = torch.jit.script(t)
x = torch.randn(2,2, dtype=torch.float, device="cuda")
y = torch.randn(2,2, dtype=torch.float, device="cuda")
scale = 0.5
jit_o = t_jit(x, y, scale)
print(jit_o.detach().cpu())
jit_o = t_jit(x, y, scale)
print(jit_o.detach().cpu())
o = t(x, y, scale)
print(o.detach().cpu())
torch._C._jit_set_nvfuser_guard_mode(old_guard)
