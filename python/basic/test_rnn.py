import torch
import torch.nn as nn

rnn = nn.RNN(10, 20, num_layers=2, dropout=.5)
device = 1
input = torch.randn(5, 4, 10).cuda(device)
rnn.cuda(device)
hx = torch.randn(2, 4, 20).cuda(device)
output = rnn(input, hx)
