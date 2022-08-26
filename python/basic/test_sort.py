import torch

tensor = torch.arange(2, device='cpu', dtype=torch.long).repeat(2000).cuda()
output,_ = tensor.sort()
print(torch.mean(output.cpu().float()))
