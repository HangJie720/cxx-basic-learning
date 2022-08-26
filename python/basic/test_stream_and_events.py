import torch
torch.set_printoptions(precision=16)

@torch.jit.script
def test_stream():
    device_index = torch.cuda._current_device()
    print("device_index:", device_index)
    current_stream = torch.cuda.current_stream(device_index)
    user_stream = torch.jit.cuda.Stream(device_index, 0)
    A = torch.rand(2, 2, device="cuda")
    with torch.jit.cuda.stream(user_stream):
        check = torch.cuda.current_stream(device_index).id() == user_stream.id()
        B = torch.mm(A, A).to("cuda")
    # Wait for B to be computed
    user_stream.synchronize()
    # Check if the stream has been reset on the current device
    is_stream_reset = torch.cuda.current_stream(device_index).id() == current_stream.id()
    return A, B, check, is_stream_reset

if __name__ == "__main__":
    t = torch.jit.script(test_stream)
    A, B, b1, b2 = t()
    A, B, b1, b2 = t()
    C = torch.matmul(A, A)
    print(A) 
    print(B)
    print(C)
