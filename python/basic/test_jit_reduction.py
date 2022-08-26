import torch

torch._C._jit_override_can_fuse_on_cpu(False)
torch._C._jit_override_can_fuse_on_gpu(False)
torch._C._jit_set_nvfuser_guard_mode(False)
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
scale = 0.5

t_jit = torch.jit.script(t)
jit_o = t_jit(scale, x, y, z)
jit_o = t_jit(scale, x, y, z)
o = t(scale, x, y, z)

print("mean:")
print("jit_o:", jit_o[0].mean(), "\t", jit_o[1].mean())
print("o:", o[0].mean(), "\t", o[1].mean())
print("std:")
print("jit_o:", jit_o[0].std(), "\t", jit_o[1].std())
print("o:", o[0].std(), "\t", o[1].std())
# print(jit_o[1].detach().cpu())
# print(o[1].detach().cpu())

torch._C._jit_set_nvfuser_guard_mode(old_guard)
