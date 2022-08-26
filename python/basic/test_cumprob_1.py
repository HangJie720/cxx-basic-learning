import torch
from torch._C import dtype

if __name__ == "__main__":
    device = "cuda"
    type = torch.int8
    t_cpu = torch.tensor(
         [[[1,2,-1], [3,4,-2]],
         [[5,6,-3], [7,8,0]]], dtype=torch.int8)

    t_device = t_cpu.to(dtype=type, device=device)
    cpu_arg = [-1]
    device_arg = [-1]
    cpu_result = t_cpu.cumprod(*cpu_arg)
    device_result = t_device.cumprod(*device_arg)
    print(cpu_result)
    print(device_result)
