import torch

TEST_WITH_COREX = torch.corex
a = torch.randn(3)
b = a.to((torch.float32 if not a.dtype.is_complex else torch.complex64) if TEST_WITH_COREX else (torch.float64 if not a.dtype.is_complex else torch.complex128))
print(b)
c = b.to((torch.float64))
print(c)
