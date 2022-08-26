from unittest import main
import torch
from torch.testing._internal.common_nn import ctcloss_reference

def test_CTCLoss_cudnn():
        target_lengths = [30, 25, 20]
        input_lengths = [50, 50, 50]
        targets = torch.randint(1, 15, (sum(target_lengths),), dtype=torch.int)
        log_probs = torch.randn(50, 3, 15, dtype=torch.float32, device="cuda").log_softmax(2)
        print(log_probs)
        #res = torch.nn.functional.ctc_loss(log_probs, targets, input_lengths, target_lengths).float()
        # expected = ctcloss_reference(log_probs.cpu(), targets.cpu(), input_lengths, target_lengths).float()
        # with torch.backends.cudnn.flags(enabled=False):
        #     res2 = torch.nn.functional.ctc_loss(log_probs, targets.cuda().long(), input_lengths, target_lengths)
        # torch.testing.assert_allclose(res.cpu(), expected)
        # torch.testing.assert_allclose(res2, res)

if __name__ == '__main__':
    test_CTCLoss_cudnn()
    
