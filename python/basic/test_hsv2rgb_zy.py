# import torch
# from torch import _VF
# import functools
# assert_equal = functools.partial(torch.testing.assert_close, rtol=0, atol=1e-6)

# def einsum_t(*args):
#     equation = args[0]
#     operands = args[1:]
#     return _VF.einsum(equation, operands)  # type: ignore[attr-defined]

# def hsv2rgb_t(img):
#     h, s, v = img.unbind(dim=-3)
#     i = torch.floor(h * 6.0)
#     f = (h * 6.0) - i
#     i = i.to(dtype=torch.int32)

#     p = torch.clamp((v * (1.0 - s)), 0.0, 1.0)
#     q = torch.clamp((v * (1.0 - s * f)), 0.0, 1.0)
#     t = torch.clamp((v * (1.0 - s * (1.0 - f))), 0.0, 1.0)
#     i = i % 6

#     mask = i.unsqueeze(dim=-3) == torch.arange(6, device=i.device).view(-1, 1, 1)

#     a1 = torch.stack((v, q, p, p, t, v), dim=-3)
#     a2 = torch.stack((t, v, v, q, p, p), dim=-3)
#     a3 = torch.stack((p, p, t, v, v, q), dim=-3)
#     a4 = torch.stack((a1, a2, a3), dim=-4)

#     return torch.einsum("...ijk, ...xijk -> ...xjk", mask.to(dtype=img.dtype), a4)

# def test_hsv2rgb(device):
#     batch_tensors = torch.randint(
#         0, 256,
#         (4, 3, 120, 100),
#         dtype=torch.uint8,
#         device=device
#     ).float()
#     batch_tensors = hsv2rgb_t(batch_tensors)

#     for i in range(len(batch_tensors)):
#         img_tensor = batch_tensors[i, ...]
#         transformed_img = hsv2rgb_t(img_tensor)
#         assert_equal(transformed_img, batch_tensors[i, ...])

# if __name__ == '__main__':
#     test_hsv2rgb('cuda')

import torch
from torch import Tensor
import functools
Tensor = torch.Tensor
assert_equal = functools.partial(torch.testing.assert_close, rtol=0, atol=1e-6)

def _test_fn_on_batch(batch_tensors, fn, scripted_fn_atol=1e-8, **fn_kwargs):
    transformed_batch = fn(batch_tensors, **fn_kwargs)
    for i in range(len(batch_tensors)):
        img_tensor = batch_tensors[i, ...]
        transformed_img = fn(img_tensor, **fn_kwargs)
        assert_equal(transformed_img, transformed_batch[i, ...])    
        if scripted_fn_atol >= 0:
            scripted_fn = torch.jit.script(fn)
            # scriptable function test
            s_transformed_batch = scripted_fn(batch_tensors, **fn_kwargs)
        torch.testing.assert_close(transformed_batch, s_transformed_batch, rtol=1e-5, atol=scripted_fn_atol)

def hsv2rgb_t(img: Tensor) -> Tensor:
    h, s, v = img.unbind(dim=-3)
    i = torch.floor(h * 6.0)
    f = (h * 6.0) - i
    i = i.to(dtype=torch.int32)    
    p = torch.clamp((v * (1.0 - s)), 0.0, 1.0)
    q = torch.clamp((v * (1.0 - s * f)), 0.0, 1.0)
    t = torch.clamp((v * (1.0 - s * (1.0 - f))), 0.0, 1.0)
    i = i % 6    
    mask = i.unsqueeze(dim=-3) == torch.arange(6, device=i.device).view(-1, 1, 1)    
    a1 = torch.stack((v, q, p, p, t, v), dim=-3)
    a2 = torch.stack((t, v, v, q, p, p), dim=-3)
    a3 = torch.stack((p, p, t, v, v, q), dim=-3)
    a4 = torch.stack((a1, a2, a3), dim=-4)    
    
    return torch.einsum("...ijk, ...xijk -> ...xjk", mask.to(dtype=img.dtype), a4)

def test_hsv2rgb(device):
    batch_tensors = torch.randint(0, 256, (4, 3, 120, 100), dtype=torch.uint8, device=device).float()
    _test_fn_on_batch(batch_tensors, hsv2rgb_t)

if __name__ == '__main__':
    test_hsv2rgb('cuda')