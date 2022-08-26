import os
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import numpy as np
import torch
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import spatial
from utils import get_stats, handle_result

a, b = 3, 5
step = 0
title = f"{a}vs{b}"
bi = np.load(f"./0720/tacotron2_0720_{a}_backward_step{step}.npy", allow_pickle=True).item()
nv = np.load(f"./0720/tacotron2_0720_{b}_backward_step{step}.npy", allow_pickle=True).item()

keys_nv = set(nv.keys())
keys_bi = set(bi.keys())
print(f"nv - bi, lens = {len(keys_nv - keys_bi)}")
if len(keys_nv - keys_bi) > 0:
    for k in set(keys_nv - keys_bi):
        print(k)
print(f"bi - nv, lens = {len(keys_bi - keys_nv)}")
if len(keys_bi - keys_nv) > 0:
    for k in set(keys_bi - keys_nv):
        print(k)

keys = list(nv.keys())
print(f"Number of modules: {len(keys)}")
for k in keys:
    print(k)

keys = list(bi.keys())
print(f"Number of modules: {len(keys)}")
for k in keys:
    print(k)

diff_rate_f = []
# distance_f = []
max_diff_f = []
threshold = 1e-3
eps = 1e-6
result = []
for k in keys:
    print(f"[{k}]")
    for mode in ["input", "output"]:
        print(f"\t[{mode}]")
        nv_data = nv[k][mode]
        bi_data = bi[k][mode]
        if isinstance(bi_data, (list, tuple)):
            for item_nv, item_bi in zip(nv_data, bi_data):
                if len(bi_data) > 0:
                    print(f"[[Multiple {mode}s]], len = {len(bi_data)}")                
                if isinstance(item_bi, torch.nn.utils.rnn.PackedSequence):
                    print(f"This is an {type(item_bi)}")
                    item_nv, item_bi = item_nv.data, item_bi.data
                    diff_rate_f, max_diff_f, result = handle_result(item_bi, item_nv, diff_rate_f, max_diff_f, result)
                elif isinstance(item_bi, torch.Tensor):
                    diff_rate_f, max_diff_f, result = handle_result(item_bi, item_nv, diff_rate_f, max_diff_f, result)
                elif isinstance(item_bi, (list, tuple)):
                    if len(item_bi) > 0:
                        print(f"[[[Multiple {mode}s]]], len = {len(item_bi)}")
                    for elem_nv, elem_bi in zip(item_nv, item_bi):
                        diff_rate_f, max_diff_f, result = handle_result(elem_bi, elem_nv, diff_rate_f, max_diff_f, result)
                        print(" + " * 20, "\n")
                else:
                    print(f"This is an {type(item_bi)}, not recognized!")
                    # result = get_stats(item_bi, item_nv)
                    # max_diff_f.append(result["max_diff"])
                    # diff_rate_f.append(result["sum_diff_rate"])                       
            print(" = " * 20, "\n")
        else:
            diff_rate_f, max_diff_f, result = handle_result(bi_data, nv_data, diff_rate_f, max_diff_f, result)
            # result = get_stats(bi_data, nv_data)
            # max_diff_f.append(result["max_diff"])
            # diff_rate_f.append(result["sum_diff_rate"])
            print(" = " * 20, "\n")          

# diff_rate_f = []
# distance_f = []
# threshold = 1e-3
# keys = list(nv.keys())
# for k in keys:
#     print(f"[{k}]")
#     for mode in ["input", "output"]:
#         print(f"\t[{mode}]")
#         nv_data = nv[k][mode]
#         bi_data = bi[k][mode]
#         if isinstance(nv_data, (list, tuple)):
#             for item_nv, item_bi in zip(nv_data, bi_data):
#                 if item_nv is None or item_bi is None:
#                     continue
#                 print(f"For nv: {item_nv.dtype}, {item_nv.shape}")
#                 print(f"For bi: {item_bi.dtype}, {item_bi.shape}")
#                 print(f"Check allclose: {torch.allclose(item_nv, item_bi)}")
#                 diff = (item_bi - item_nv).abs().to(torch.float32)
#                 max_diff = diff.max()
#                 mean_diff = diff.mean()
#                 print(f"max_diff = {max_diff}, mean_diff = {mean_diff}")
#                 print(f"Check sums")
#                 sum_nv = item_nv.abs().to(torch.float32).sum()
#                 sum_bi = item_bi.abs().to(torch.float32).sum()
#                 sum_diff = diff.to(torch.float32).sum()
#                 sum_diff_rate = sum_diff / sum_nv
#                 diff_rate_f.append(sum_diff_rate.item())
#                 print(f"nv sum = {sum_nv}, bi sum = {sum_bi}, diff sum = {sum_diff}")
#                 print(f"diff sum rate = {sum_diff_rate}")
#                 distance = spatial.distance.cosine(item_nv.cpu().contiguous().view(-1).float(), item_bi.cpu().contiguous().view(-1).float())
#                 distance_f.append(distance)
#                 print(f"spatial cosine distance = {distance}")
#             print(" = " * 20, "\n")
#         else:
#             item_nv, item_bi = nv_data, bi_data
#             print(f"For nv: {item_nv.dtype}, {item_nv.shape}")
#             print(f"For bi: {item_bi.dtype}, {item_bi.shape}")
#             print(f"Check allclose: {torch.allclose(item_nv, item_bi)}")
#             diff = (item_bi - item_nv).abs().to(torch.float32)
#             max_diff = diff.max()
#             mean_diff = diff.mean()
#             print(f"max_diff = {max_diff}, mean_diff = {mean_diff}")
#             print(f"Check sums")
#             sum_nv = item_nv.abs().to(torch.float32).sum()
#             sum_bi = item_bi.abs().to(torch.float32).sum()
#             sum_diff = diff.to(torch.float32).sum()
#             sum_diff_rate = sum_diff / sum_nv
#             diff_rate_f.append(sum_diff_rate.item())
#             print(f"nv sum = {sum_nv}, bi sum = {sum_bi}, diff sum = {sum_diff}")
#             print(f"diff sum rate = {sum_diff_rate}")
#             distance = spatial.distance.cosine(item_nv.cpu().contiguous().view(-1).float(), item_bi.cpu().contiguous().view(-1).float())
#             distance_f.append(distance)
#             print(f"spatial cosine distance = {distance}")
#             print(" = " * 20, "\n")          

diff_rate_f = np.array(diff_rate_f)
print(len(diff_rate_f))
print(diff_rate_f)
print(max(diff_rate_f))

# 1. Lineplot
plt.figure(figsize=(10, 6))
sns.lineplot(x=range(1, len(diff_rate_f)+1), y=diff_rate_f)
plt.title("Backward diff abs sum rate")
plt.xlabel("Layers")
plt.ylabel("rate")
plt.grid()
plt.savefig(f"tacotron2_0720_backward_data_diff_abs_sum_rate_{title}.png", dpi=150)
plt.show()

# 2. Futher check diff_rate_f
print(f"len(diff_rate_f) = {len(diff_rate_f)}")
n = 0
for (k, v) in zip(keys, diff_rate_f):
    if v >= 0.5:
        print(f"key = {k}, value = {v}")
        n += 1
print(f"len(failed) = {n}")

# # Cosine distance
# distance_f = np.array(distance_f)
# print(len(distance_f))
# print(distance_f)
# print(max(distance_f))

# # 1. Lineplot
# plt.figure(figsize=(10, 6))
# sns.lineplot(x=range(1, len(distance_f)+1), y=distance_f)
# plt.title("Backward cosine distance")
# plt.xlabel("Layers")
# plt.ylabel("rate")
# plt.grid()
# plt.savefig(f"tacotron2_0720_backward_data_cosine_distance_{title}.png", dpi=150)
# plt.show()

# # Check a specific node
# k = "heads_only_segment.cls.predictions.transform.dense"
# import pandas as pd
# data = pd.DataFrame({'nv': nv[k][mode][0].flatten().tolist(), 'bi': bi[k][mode][0].flatten().tolist()})
# # data['abs_diff'] = (data['nv'] - data['bi']).abs()
# # data['rel_diff'] = data['abs_diff'] / (data['nv'].abs() + 1e-6)

# plt.figure(figsize=(12, 8))
# sns.scatterplot(x='nv', y='bi', data=data)
# plt.title(f"Bert backward data elem-wise comparison -- [{k}]")
# plt.savefig(f"Bert Backward data elem-wise comparison -- [{k}].png")
# plt.show()

max_diff_f = np.array(max_diff_f)
from itertools import compress
keys_failed = list(compress(keys, list(max_diff_f > 0.01)))
max_diff_f = max_diff_f[max_diff_f > 0.01]
for (k, diff) in zip(keys_failed, max_diff_f):
    print(k, diff)
print("max_diff_f failed ", len(max_diff_f))