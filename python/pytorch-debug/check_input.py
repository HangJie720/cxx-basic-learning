import os
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import math
import numpy as np
import torch
from scipy import spatial


m, n = 6, 7


def get_stats(bi, nv):
    bi = bi.cpu()
    nv = nv.cpu()
    print(f"Tensor shape is {bi.shape}")
    print(f"allclose = {torch.allclose(bi, nv)}")
    diff = (bi - nv).abs()
    max_diff = diff.max()
    mean_diff = diff.mean()
    print(f"max_diff = {max_diff}, mean_diff = {mean_diff}")
    print(f"Check sums")
    sum_nv = nv.abs().to(torch.float32).sum()
    sum_bi = bi.abs().to(torch.float32).sum()
    sum_diff = diff.to(torch.float32).sum()
    sum_diff_rate = sum_diff / sum_nv
    print(f"nv sum = {sum_nv}, bi sum = {sum_bi}, diff sum = {sum_diff}")
    print(f"diff sum rate = {sum_diff_rate}")
    distance = spatial.distance.cosine(nv.detach().cpu().contiguous().view(-1).float(), bi.detach().cpu().contiguous().view(-1).float())
    print(f"spatial cosine distance = {distance}")
    print(" =" * 10)
    print("\n")

def load_data(m=1, n=2):

    bi = torch.load(f"./0720/tacotron2_0720_{m}_input_step0.pt")
    nv = torch.load(f"./0720/tacotron2_0720_{n}_input_step0.pt")
    
    # bi, nv = bi['batch'], nv['batch']
    for item_bi, item_nv in zip(bi, nv):
        get_stats(item_bi.to(torch.float32), item_nv.to(torch.float32))

if __name__ == "__main__":
    load_data(0, 1)