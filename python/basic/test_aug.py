import torch
from torchvision import transforms

import random
import numpy as np


def same_seeds(seed):
    # Python built-in random module
    random.seed(seed)
    # Numpy
    np.random.seed(seed)
    # transformsorch
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.benchmark = False
    torch.backends.cudnn.deterministic = True


if __name__ == '__main__':

    same_seeds(2021)
    input = torch.randn(16, 3, 224, 224).cuda()
    input.requires_grad = True
    augs = transforms.Compose([
              #transforms.RandomHorizontalFlip(p=0.5),
              #transforms.RandomGrayscale(p=0.1),
              transforms.ColorJitter(hue=0.1),
          ])
    # print("input mean is: ", input.mean())
    # print("input var is: ", input.var())
    # print("input sum is: ", input.sum())
    x = augs(input)
    # print("x mean is: ", x.mean())
    # print("x var is: ", x.var())
    # print("x sum is: ", x.sum())
    # 测试反向梯度
    grad = torch.autograd.grad(x.sum(), input)[0]
    print('grad sum = ', grad.sum())


