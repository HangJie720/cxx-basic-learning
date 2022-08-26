import torch
dtype = torch.half
#dtype = torch.float
device = "cuda"
return_inverse=True
return_counts=True
x = torch.tensor([1, 2, 3, 2, 8, 5, 2, 3], dtype=dtype, device=device)
expected_unique = torch.tensor([1, 2, 3, 5, 8], dtype=dtype, device=device)
expected_inverse = torch.tensor([0, 1, 2, 1, 4, 3, 1, 2], device=device)
expected_counts = torch.tensor([1, 3, 2, 1, 1], device=device)
a = torch.unique(x, return_inverse=return_inverse, return_counts=return_counts)
#print(a)
