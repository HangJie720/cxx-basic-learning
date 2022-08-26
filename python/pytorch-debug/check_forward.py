import os
os.environ["CUDA_VISIBLE_DEVICES"] = "0"
import numpy as np
import torch
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import spatial
from utils import get_stats, handle_result

a, b = 6, 7
step = 0
title = f"{a}vs{b}"
bi = np.load(f"./0720/tacotron2_0720_{a}_forward_step{step}.npy", allow_pickle=True).item()
nv = np.load(f"./0720/tacotron2_0720_{b}_forward_step{step}.npy", allow_pickle=True).item()

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

diff_rate_f = np.array(diff_rate_f)
print(len(diff_rate_f))
print(diff_rate_f)
print(max(diff_rate_f))

# 1. Lineplot
plt.figure(figsize=(10, 6))
sns.lineplot(x=range(1, len(diff_rate_f)+1), y=diff_rate_f)
plt.title("Forward diff abs sum rate")
plt.xlabel("Layers")
plt.ylabel("rate")
plt.grid()
plt.savefig(f"tacotron2_0720_forward_data_diff_abs_sum_rate_{title}.png", dpi=150)
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
# plt.title("Forward cosine distance")
# plt.xlabel("Layers")
# plt.ylabel("rate")
# plt.grid()
# plt.savefig(f"tacotron2_0720_forward_data_cosine_distance_{title}.png", dpi=150)
# plt.show()

max_diff_f = np.array(max_diff_f)
from itertools import compress
keys_failed = list(compress(keys, list(max_diff_f > 0.01)))
max_diff_f = max_diff_f[max_diff_f > 0.01]
for (k, diff) in zip(keys_failed, max_diff_f):
    print(k, diff)
print("max_diff_f failed ", len(max_diff_f))