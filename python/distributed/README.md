# Distributed collectives

Eight 8-rank smoke tests for the NCCL collective primitives used by data parallel, tensor parallel, and FSDP. Each case is one `test_*.py` plus a matching `run_*.sh`.

## How to run

```bash
cd python/distributed
./run_allreduce.sh
./run_broadcast.sh --N 4096 --root 2 --dtype float16
```

- Needs 8 GPUs. `NPROC_PER_NODE` defaults to 8.
- `torchrun` injects `RANK`, `WORLD_SIZE`, and `LOCAL_RANK`. Backend defaults to NCCL; each rank uses `cuda:LOCAL_RANK`.
- Every rank must enter the same collective with the same length and dtype.
- `root` / `src` / `dst` are **rank ids**, not CUDA device ids.
- Each `run_*.sh` uses a different default `MASTER_PORT` (29500–29507) so cases can run back to back.

## Cases

### 1. AllReduce — `test_allreduce.py` / `run_allreduce.sh`

Reduce across all ranks (sum / min / max / …), then leave the full result on **every** rank.

- Check: `out[i] = in0[i] + … + in7[i]`
- Input: constant `rank + 1` → every rank expects `36`
- Typical use: DDP gradient sync
- API: `dist.all_reduce` / `ncclAllReduce`

### 2. Broadcast — `test_broadcast.py` / `run_broadcast.sh`

Copy a length-`N` buffer from `--root` (default `2`) to every other rank.

- Check: every rank ends with `out[i] = in_root[i]`
- Root fills `in[i] = i + root + 1`; other ranks start at 0
- Typical use: broadcast initial weights from the main process
- API: `dist.broadcast` / `ncclBroadcast`

### 3. Reduce — `test_reduce.py` / `run_reduce.sh`

Same reduce math as AllReduce, but only `--root` (default `2`) keeps the result. Other ranks are not checked.

- Check on root: `out[i] = in0[i] + … + in7[i]` → `36`
- Typical use: parameter-server style gradient reduce
- Identity: `Reduce + Broadcast = AllReduce`
- API: `dist.reduce` / `ncclReduce`

### 4. AllGather — `test_allgather.py` / `run_allgather.sh`

Each of `k` ranks holds `N` elements. Concatenate into a `k * N` buffer and deliver that full buffer to **every** rank, ordered by rank id.

- Check: `out[Y * N + i] = inY[i]`, with `inY = Y + 1`
- Typical use: gather sharded parameters in FSDP / tensor parallel
- Identity: `ReduceScatter + AllGather = AllReduce`
- API: `dist.all_gather` / `ncclAllGather`

### 5. ReduceScatter — `test_reducescatter.py` / `run_reducescatter.sh`

Reduce first, then split the result into `k` equal chunks. Rank `Y` keeps only chunk `Y`.

- Input layout is identical on every rank: chunk `Y` filled with `Y + 1`
- Check: rank `Y` expects `8 * (Y + 1)`
- Typical use: FSDP backward, tensor parallel
- API: `dist.reduce_scatter` / `ncclReduceScatter`

### 6. AlltoAll — `test_alltoall.py` / `run_alltoall.sh`

Each rank’s input is `k * N`, split into `k` segments of length `N`. Rank `Y` sends segment `X` to rank `X`. Rank `X` stores the chunk from rank `Y` in slot `Y`.

- Segment value: `(Y + 1) * 100 + (X + 1)`
- Check: `outX[Y * N + i] = inY[X * N + i]`
- Typical use: MoE token routing / expert rearrange
- API: `dist.all_to_all` / `ncclAlltoAll`

### 7. Gather — `test_gather.py` / `run_gather.sh`

Same concatenation as AllGather, but only `--root` (default `2`) holds the `k * N` result.

- Check on root: `out[Y * N + i] = inY[i]`, with `inY = Y + 1`
- Typical use: main process collects per-rank outputs
- API: `dist.gather` / `ncclGather`

### 8. Scatter — `test_scatter.py` / `run_scatter.sh`

`--root` (default `2`) holds `k * N` elements, splits into `k` chunks of length `N`, and sends chunk `X` to rank `X`.

- Root chunk `X` is filled with `X + 1`
- Check: rank `X` expects `X + 1`
- Typical use: main process hands each GPU its shard
- API: `dist.scatter` / `ncclScatter`

## Useful identities

1. `Reduce + Broadcast = AllReduce`
2. `ReduceScatter + AllGather = AllReduce`

Large-scale training often implements AllReduce as ReduceScatter plus AllGather, which moves less data than a direct AllReduce.

## Reference

[03_看懂多卡分布式训练：一文读懂NCCL八大集合通信原语](https://mp.weixin.qq.com/s?__biz=MzkxNDQ5MTI2OA==&mid=2247487813&idx=1&sn=de38842ba5735b88ab837d2512bea005&chksm=c16cc3aef61b4ab8a976f43fdd8d39a861431acc95eca7f3bfe30ab53b8e02b55c7dfc68cd8a&cur_album_id=4770922934775611392&scene=189#wechat_redirect)
