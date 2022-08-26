import torch
import torch.testing._internal.jit_metaprogramming_utils

def a():
    tensor1 = torch.rand(10000, 10000, device="cuda")
    print("\ntensor1.type:", tensor1.dtype)
    print("\ndouble:", torch.double)
    print("\nfloat:", torch.float)
    tensor2 = torch.mm(tensor1, tensor1).to("cuda")

a()
