import torch
from torch._C import dtype

if __name__ == "__main__":
    device = "cuda"
    type = torch.int8
    t_cpu = torch.tensor([[[ 0, -4,  1,  0,  1],
         [-1, -3,  0,  0,  4],
         [-2, -4, -1, -3, -2],
         [-3,  1,  3, -3, -3],
         [ 3, -3, -5, -1,  4]],        [[-3, -4,  4, -3, -3],
         [ 4, -1, -1,  2, -3],
         [ 0,  3,  1,  1,  2],
         [-4,  0, -3, -4,  2],
         [-1, -2, -5,  2,  1]],        [[ 4, -2, -2,  4, -5],
         [-4, -3,  4,  2,  3],
         [ 1, -2, -1,  3,  0],
         [-4,  0,  1, -1, -3],
         [ 4, -2,  0,  4,  2]],        [[ 4,  4, -1,  4,  3],
         [ 2, -1,  0, -3,  3],
         [ 3,  3,  3, -1, -1],
         [-3, -2,  4, -4, -3],
         [ 2, -3,  3,  0,  2]],        [[ 3,  4, -3,  4, -2],
         [-1,  4, -3,  1, -3],
         [ 2,  4,  3, -3,  3],
         [-1,  1, -4,  2,  2],
         [-4, -3, -2, -3, -4]]], dtype=torch.int8)
    t_device = t_cpu.to(dtype=type, device=device)
    cpu_arg = [1]
    device_arg = [1]
    cpu_result = t_cpu.cumprod(*cpu_arg)
    device_result = t_device.cumprod(*device_arg)
    print(cpu_result)
    print(device_result)
