import torch 
import torchvision.transforms.functional_tensor as F_t
device = "cuda"

def _create_data_batch(height=3, width=3, channels=3, num_samples=4, device="cpu"):
    # TODO: When all relevant tests are ported to pytest, turn this into a module-level fixture
    batch_tensor = torch.randint(
        0, 256,
        (num_samples, channels, height, width),
        dtype=torch.uint8,
        device=device
    )
    return batch_tensor

def _test_fn_on_batch(batch_tensors, fn, scripted_fn_atol=1e-8, **fn_kwargs):
    transformed_batch = fn(batch_tensors, **fn_kwargs)


batch_tensors = _create_data_batch(120, 100, num_samples=4, device=device).float()
_test_fn_on_batch(batch_tensors, F_t._hsv2rgb)
