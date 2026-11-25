# Conv3dAlgoPrecision

Load NCDHW BF16 tensors from a `golden/` directory and sweep cuDNN FWD algorithms
for a 3D convolution, comparing outputs to a self / Get-selected baseline.

## Golden layout

```
golden/
  padded.bf16.bin
  weight.bf16.bin
  bias.bf16.bin
  meta.json          # optional; shapes / stride / padding if required by the binary
  out_golden.bf16.bin  # optional external reference
```

Place tensors under `./golden` or set `GOLDEN=/path/to/golden`.

## Run

```bash
cd Conv3dAlgoPrecision
# GOLDEN=/path/to/golden bash run.sh
bash run.sh
```

Outputs: `summary.json`, `report.xlsx`, `out_golden/`.

## Build only

```bash
bash make.sh
./conv3d_algo_precision --help
```
