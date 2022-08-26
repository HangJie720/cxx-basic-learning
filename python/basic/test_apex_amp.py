import torch
import torch.nn as nn
from apex import amp

handle = amp.init(enabled=False)
torch.set_default_tensor_type(torch.cuda.FloatTensor)

rnn = nn.LSTM(input_size=64, hidden_size=64, num_layers=1, bidirectional=False)
x = torch.randn((10, 16, 64), dtype=torch.float).requires_grad_()
hidden = (torch.zeros((1, 16, 64), dtype=torch.float), 
          torch.zeros((1, 16, 64), dtype=torch.float))

o1, o2 = rnn(x, hidden)
#print(o1)
#print(o2)

handle._deactivate()
