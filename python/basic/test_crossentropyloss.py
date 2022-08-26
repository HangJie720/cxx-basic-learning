import numpy as np
import torch
from torch import nn


class RectifiedCrossEntropyLoss(nn.Module):

    def __init__(self, reduction='mean'):
        super().__init__()
        self.loss_fn = nn.CrossEntropyLoss(reduction=reduction)

    def forward(self, pred, target):
        # (B, num_classes, H, W) -> (B*H*W, num_classes)
        pred = pred.permute(0, 2, 3, 1).reshape(-1, pred.size()[1])
        # (B, H, W) -> (B*H*W,)
        target = target.view(-1)
        return self.loss_fn(pred, target)


if __name__ == '__main__':
    seed = 12345678
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

    pred = torch.randn(16, 12, 353, 481) * 5
    pred = pred.cuda()
    target = torch.randint(0, 12, (16, 353, 481)).long()
    target = target.cuda()

    print('pred:', np.unique(pred.cpu().numpy()))
    print('target:', np.unique(target.cpu().numpy()))

    loss_fn = nn.CrossEntropyLoss()
    loss = loss_fn(pred, target)
    #print('CrossEntropyLoss:', loss)

    #new_loss_fn = RectifiedCrossEntropyLoss()
    #loss = new_loss_fn(pred, target)
    #print('RectifiedCrossEntropyLoss:', loss)
