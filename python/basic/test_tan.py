import torch

tensor = torch.scalar_tensor(-1.0000e+20).cuda()
# print(tensor)
result_cpu = torch.tan(tensor.detach().cpu())
result_cuda = torch.tan(tensor)
# print("result_cpu is: ", result_cpu)
# print("result_cuda is: ", result_cuda)