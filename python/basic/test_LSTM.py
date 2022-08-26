import torch
from torch import _VF

bias = True
num_layers=1
dropout=0.0
training=False
bidirectional=True
batch_sizes = torch.tensor([13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 12, 12, 12, 12, 12, 12,
        12, 12, 11, 11, 11, 11, 11, 11, 10,  9,  9,  8,  8,  8,  8,  8,  8,  8,
         8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  7,
         7,  7,  7,  7,  7,  7,  7,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  4,
         4,  3,  2,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
         1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
         1,  1,  1,  1,  1,  1,  1,  1,  1],dtype=torch.int64)
print("batch_sizes is: ", batch_sizes)
print("batch_sizes is: ", batch_sizes.dtype)
weights = torch.load("weight.pt")
input = torch.load("input.pt")
# for weight in weights:
#     print("weight if is nan: ", torch.any(torch.isnan(weight)))
# print("input if is nan: ", torch.any(torch.isnan(input)))
# print("weights is: ", weights)
# print("input is: ", input)
h_zeros = torch.zeros(2, 13, 256, dtype=input.dtype, device="cuda")
c_zeros = torch.zeros(2, 13, 256, dtype=input.dtype, device="cuda")
hx = (h_zeros, c_zeros)

result = _VF.lstm(input, batch_sizes, hx, weights, bias,
                  num_layers, dropout, training, bidirectional)
if (torch.any(torch.isnan(result[0]))):
    print("LSTM output is nan: ", result[0])

