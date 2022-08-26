import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

class MyModel(nn.Module):
 def __init__(self, n_featuresroot = 8, in_channels = 1, out_channels =1):
  super(MyModel, self).__init__()
  self.conv1_1 =nn.Sequential(nn.Conv2d(in_channels, n_featuresroot, kernel_size=3, padding=0), nn.ReLU())
  self.conv1_2 =nn.Sequential(nn.Conv2d(n_featuresroot, n_featuresroot, kernel_size=3, padding=0), nn.ReLU())
 def forward(self, x):
  conv1_1 = self.conv1_1(x)
  conv1_2 = self.conv1_2(conv1_1)
  return conv1_2

torch.cuda.empty_cache()
network = MyModel()
network.cuda()
network.eval()
dummy_input = torch.zeros((1, 1, 512, 512), dtype=torch.float32).cuda()
out = network(dummy_input)
traced_script_module = torch.jit.trace(network, dummy_input)
traced_script_module.save('./model.pt')
