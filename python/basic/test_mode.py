import torch
device= "cuda"

def _test_mode_intervals(shape, intervals, device, v=1):
        x = torch.arange(0, shape[0] * shape[1], device=device)
        x[v] = x.numel()
        x = x.resize_(shape)

        for (beg, end) in intervals:
            x[:, beg:end] = v

        values, indices = torch.mode(x, -1, False)

def testset_for_shape(shape, i):
    d = shape[-1]
    _test_mode_intervals(shape, [(0, i), (i + 1, d - i - 1), (d - i, d)], device)

testset_for_shape((10, 2048), 10)
