import torch

dtype = torch.float
device = "cuda"

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
expected_unique_dim2 = torch.tensor([[[1., 1.],
                                      [0., 1.],
                                      [2., 1.],
                                      [0., 1.]],
                                     [[1., 1.],
                                      [0., 1.],
                                      [2., 1.],
                                      [0., 1.]]],
                                      dtype=dtype,
                                      device=device)
b = torch.unique(x, dim=2)

# print("expected_unique_dim2 is: ", expected_unique_dim2)
print("b is: ", b)

# torch.testing.assert_allclose(expected_unique_dim2, b)

