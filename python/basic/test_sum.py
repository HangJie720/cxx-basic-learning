import torch
from torch._C import dtype

if __name__ == "__main__":
    device = "cuda"
    type = torch.int8
    t_cpu = torch.tensor(
         [[[1,-1], [3,-2]],
         [[5,-3], [7,-4]]], dtype=type)
    t_device = t_cpu.to(dtype=type, device=device)
    cpu_arg = [-1]
    device_arg = [-1]
    cpu_result = t_cpu.sum(*cpu_arg)
    device_result = t_device.sum(*device_arg)
    #print(cpu_result)
    #print(device_result)
