import torch
import numpy as np

input = torch.randn(1083).cuda()
input = input.to(torch.long)
print(input.shape)
return_inverse=False
return_counts=False
sorted=True
output, inverse_indices, counts = torch._unique2(
            input,
            sorted=sorted,
            return_inverse=return_inverse,
            return_counts=return_counts,
        )

#print(output.shape)
#print(inverse_indices.shape)
#print(counts)
