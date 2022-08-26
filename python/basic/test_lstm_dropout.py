import torch

model = torch.nn.LSTM(512, 512, 2, dropout=0.5).cuda()
x = torch.ones(100, 192, 512, device="cuda")

y = model(x)
