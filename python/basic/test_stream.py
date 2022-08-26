import torch

device_index = 0
print("device_index:", device_index)
current_stream = torch.cuda.current_stream(device_index)
user_stream = torch.cuda.Stream(device_index, 0)
# user_stream = current_stream
A = torch.rand(1, 1, device="cuda")
with torch.cuda.stream(user_stream):
    # check = torch.cuda.current_stream(device_index).id() == user_stream.id()
    B = torch.mm(A, A).to("cuda")
# Wait for B to be computed
# current_stream.synchronize()
user_stream.synchronize()
print(A)
print(B)
