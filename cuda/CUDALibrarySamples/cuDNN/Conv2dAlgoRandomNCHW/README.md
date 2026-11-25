# Conv2dAlgoRandomNCHW

Generate random BF16 NCHW input/weight/bias, run `cudnnConvolutionForward` for FWD algos 0–7,
record Get/Find selection, and compare supported algorithms against a self baseline.

## Quick start

```bash
cd Conv2dAlgoRandomNCHW
bash run.sh
# optional:
# SEED=42 SHAPE=1,32,28,28,64,3,3 bash run.sh
```

Outputs: `summary.json`, `report.xlsx`, `golden/`.

## ResNet50-like shapes

```bash
SEED=42 bash run_resnet50.sh
```

Uses `resnet50_shapes.tsv` (ImageNet 224, N=1 stem / bottleneck / downsample).
Outputs: `results_resnet50/*.json`, `report_resnet50.xlsx`.

## Build only

```bash
bash make.sh
./conv2d_algo_precision --help
```
