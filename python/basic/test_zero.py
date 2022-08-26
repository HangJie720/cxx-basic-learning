import torch
x=torch.zeros([204800,1],dtype=torch.float,device='cuda')
y=torch.zeros([1,4],dtype=torch.float,device='cuda')
z=x @ y
print(z)
