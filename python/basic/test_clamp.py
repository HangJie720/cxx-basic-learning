import torch

torch._C._jit_set_profiling_executor(True)
torch._C._jit_set_profiling_mode(True)
torch._C._jit_override_can_fuse_on_cpu(True)
torch._C._jit_override_can_fuse_on_gpu(True)
torch._C._debug_set_fusion_group_inlining(False)
torch._C._jit_set_texpr_fuser_enabled(True)

def func2(a, b):
    return torch.clamp(a + b, min=0, max=2)

device = 'cuda'
a = torch.randn(4, 4, dtype=torch.float, device=device, requires_grad=True)
nan = torch.tensor(float('nan'), dtype=torch.float, device=device)

scripted_fn = torch.jit.script(func2)
script_outputs = scripted_fn(a,nan)
opt_script_outputs = scripted_fn(a,nan)

python_outputs = func2(a, nan)
print(script_outputs.detach().cpu())
print(opt_script_outputs.detach().cpu())
print(python_outputs.detach().cpu())
