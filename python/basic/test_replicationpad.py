import torch
import numpy as np

torch.manual_seed(15)
a_tensor = torch.from_numpy(np.array([[[1,2,3],[4,5,6]]], dtype='float32')).to('cuda')
print(a_tensor)
a_tensor = a_tensor.unsqueeze(dim=0).to(torch.float32)
b = torch.nn.functional.pad(a_tensor, [2, 2, 2, 2], mode='replicate', value=float(0))
# b = b.to(torch.uint8)
print(b)
