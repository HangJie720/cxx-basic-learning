import torch
# dtype = torch.half
dtype = torch.float
device = "cuda"
return_inverse=True
return_counts=True
x = torch.tensor([[[1., 1.],
                   [0., 1.],
                   [2., 1.],
                   [0., 1.]],
                  [[1., 1.],
                   [0., 1.],
                   [2., 1.],
                   [0., 1.]]],
                 dtype=dtype,
                 device=device)
expected_unique_dim1 = torch.tensor([[[0., 1.],
                                      [1., 1.],
                                      [2., 1.]],
                                     [[0., 1.],
                                      [1., 1.],
                                      [2., 1.]]],
                                      dtype=dtype,
                                      device=device)
a = torch.unique(x, dim=1)

torch.testing.assert_allclose(expected_unique_dim1, a)
print(a)
