import torch
x=torch.zeros([204800,1],dtype=torch.half,device='cuda')
y=torch.zeros([1,4],dtype=torch.half,device='cuda')
z=x @ y
