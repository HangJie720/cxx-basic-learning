import os
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import numpy as np
import torch
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import spatial
import pandas as pd
from utils import get_stats

a, b = 6, 7
title = f"{a}vs{b}"
step = 0
comp_key = "grad" #"state_dict"
# bi = torch.load(f"0602/tacotron2_0602_{a}_param_init.pt")
# nv = torch.load(f"0602/tacotron2_0602_{b}_param_init.pt")
bi = torch.load(f"./0720/tacotron2_0720_{a}_param_step{step}.pt")[comp_key]
nv = torch.load(f"./0720/tacotron2_0720_{b}_param_step{step}.pt")[comp_key]

keys_nv = set(nv.keys())
keys_bi = set(bi.keys())
print(f"nv - bi = {keys_nv - keys_bi}")
print(f"bi - nv = {keys_bi - keys_nv}")

keys = list(nv.keys())
print(f"Number of modules: {len(keys)}")
print(keys)

keys = list(bi.keys())
print(f"Number of modules: {len(keys)}")
print(keys)

# keys = nv['grad'].keys()
# keys_nv = set(nv['grad'].keys())
# keys_bi = set(bi['grad'].keys())
# print(f"nv - bi = {keys_nv - keys_bi}")
# print(f"bi - nv = {keys_bi - keys_nv}")




keys = nv.keys()
print(f"Number of keys is {len(keys)}")
print("The keys are listed below")
for k in keys:
    print(k)
print(" =" * 15)
diff_rate_f = []
# distance_f = []
max_diff_f = []
threshold = 1e-3
eps = 1e-6
results = []
for k in keys:
    print(f"[{k}]")
    nv_data = nv[k]
    bi_data = bi[k]
    if isinstance(nv_data, (list, tuple)):
        for item_nv, item_bi in zip(nv_data, bi_data):
            result = get_stats(item_bi, item_nv)
            max_diff_f.append(result["max_diff"])
            diff_rate_f.append(result["sum_diff_rate"])
        print(" = " * 20, "\n")
    else:
        result = get_stats(bi_data, nv_data)
        max_diff_f.append(result["max_diff"])
        diff_rate_f.append(result["sum_diff_rate"])
        print(" = " * 20, "\n")           


diff_rate_f = np.array(diff_rate_f)
print(len(diff_rate_f))
print(diff_rate_f)
print(max(diff_rate_f))

# 1. Lineplot
plt.figure(figsize=(10, 6))
sns.lineplot(x=range(1, len(diff_rate_f)+1), y=diff_rate_f)
plt.title(f"{comp_key} diff abs sum rate")
plt.xlabel("Layers")
plt.ylabel("rate")
plt.grid()
plt.savefig(f"tacotron2_{comp_key}_diff_abs_sum_rate_{title}.png", dpi=150)
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
# plt.title(f"{comp_key} cosine distance")
# plt.xlabel("Layers")
# plt.ylabel("rate")
# plt.grid()
# plt.savefig(f"tacotron2_{comp_key}_cosine_distance_{title}.png", dpi=150)
# plt.show()

# 2. Futher check distance_f
# print(f"len(distance_f) = {len(distance_f)}")
# n = 0
# for (k, v) in zip(keys, distance_f):
#     if v >= 0.1:
#         print(f"key = {k}, value = {v}")
#         n += 1
# print(f"len(failed) = {n}")

# Check a specific node

def scatter_plot(k):
    if isinstance(nv[mode][k], (list, tuple)):
        data = pd.DataFrame({'nv': nv[mode][k][0].flatten().tolist(), 'bi': bi[mode][k][0].flatten().tolist()})
    else:
        data = pd.DataFrame({'nv': nv[mode][k].flatten().tolist(), 'bi': bi[mode][k].flatten().tolist()})
    # data['abs_diff'] = (data['nv'] - data['bi']).abs()
    # data['rel_diff'] = data['abs_diff'] / (data['nv'].abs() + 1e-6)

    plt.figure(figsize=(12, 8))
    sns.scatterplot(x='nv', y='bi', data=data)
    plt.title(f"tacotron2 grad elem-wise comparison -- [{k}]")
    plt.savefig(f"tacotron2 grad elem-wise comparison -- [{k}].png")
    plt.show()

# k = "heads_only_segment.cls.predictions.transform.dense.bias"
# scatter_plot(k)

# k = "heads_only_segment.cls.predictions.transform.dense.weight"
# scatter_plot(k)

max_diff_f = np.array(max_diff_f)
from itertools import compress
keys_failed = list(compress(keys, list(max_diff_f > 0.01)))
max_diff_f = max_diff_f[max_diff_f > 0.01]
for (k, diff) in zip(keys_failed, max_diff_f):
    print(k, diff)
print("max_diff_f failed ", len(max_diff_f))