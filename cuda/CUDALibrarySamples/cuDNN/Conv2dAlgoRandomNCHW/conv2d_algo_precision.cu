/*
 * Random NCHW 4D Conv2d: sweep all FWD algos and check whether supported
 * algorithms agree bit-exactly (or within reported diffs) on NVIDIA cuDNN.
 *
 * Usage:
 *   ./conv2d_algo_precision [--seed 123] [--shape N,C,H,W,K,R,S]
 *       [--algos all] [--baseline self] [--out summary.json]
 *       [--save-golden DIR]
 */

#include <cudnn.h>
#include <cuda_runtime.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <sstream>
#include <string>
#include <vector>

#define CHECK_CUDA(expr)                                                       \
  do {                                                                         \
    cudaError_t _e = (expr);                                                   \
    if (_e != cudaSuccess) {                                                   \
      std::cerr << "CUDA " << __FILE__ << ":" << __LINE__ << " "               \
                << cudaGetErrorString(_e) << std::endl;                        \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

#define CHECK_CUDNN(expr)                                                      \
  do {                                                                         \
    cudnnStatus_t _s = (expr);                                                 \
    if (_s != CUDNN_STATUS_SUCCESS) {                                          \
      std::cerr << "cuDNN " << __FILE__ << ":" << __LINE__ << " "              \
                << cudnnGetErrorString(_s) << std::endl;                       \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

namespace {

struct Shape4 {
  int n, c, h, w;
  size_t numel() const {
    return (size_t)n * (size_t)c * (size_t)h * (size_t)w;
  }
};

static const char *algo_name(cudnnConvolutionFwdAlgo_t a) {
  switch ((int)a) {
  case 0: return "IMPLICIT_GEMM";
  case 1: return "IMPLICIT_PRECOMP_GEMM";
  case 2: return "GEMM";
  case 3: return "DIRECT";
  case 4: return "FFT";
  case 5: return "FFT_TILING";
  case 6: return "WINOGRAD";
  case 7: return "WINOGRAD_NONFUSED";
  default: return "UNKNOWN";
  }
}

static float bf16_bits_to_f32(uint16_t bits) {
  uint32_t u = ((uint32_t)bits) << 16;
  float f;
  std::memcpy(&f, &u, sizeof(f));
  return f;
}

static uint16_t f32_to_bf16_bits(float f) {
  uint32_t u;
  std::memcpy(&u, &f, sizeof(u));
  uint32_t rounding_bias = ((u >> 16) & 1u) + 0x7FFFu;
  return (uint16_t)((u + rounding_bias) >> 16);
}

struct DiffStats {
  bool exact = true;
  size_t numel = 0;
  size_t non_equal = 0;
  double mae = 0, max_abs = 0, mse = 0, rmse = 0;
  double mean_rel = 0, max_rel = 0, rel_l2 = 0;
  double cosine_sim = 0, pearson = 0, similarity = 0;
};

static DiffStats diff_bf16(const uint16_t *a, const uint16_t *b, size_t n) {
  DiffStats s;
  s.numel = n;
  if (!n) return s;
  const double eps = 1e-12;
  double abs_sum = 0, abs_sq = 0, rel_sum = 0;
  double max_abs = 0, max_rel = 0;
  double dot = 0, na = 0, nb = 0;
  double sum_a = 0, sum_b = 0, sum_aa = 0, sum_bb = 0, sum_ab = 0;
  for (size_t i = 0; i < n; ++i) {
    if (a[i] != b[i]) { s.exact = false; ++s.non_equal; }
    double fa = bf16_bits_to_f32(a[i]);
    double fb = bf16_bits_to_f32(b[i]);
    double d = std::fabs(fa - fb);
    if (d > max_abs) max_abs = d;
    abs_sum += d;
    abs_sq += d * d;
    double rel = d / (std::fabs(fb) + eps);
    rel_sum += rel;
    if (rel > max_rel) max_rel = rel;
    dot += fa * fb; na += fa * fa; nb += fb * fb;
    sum_a += fa; sum_b += fb; sum_aa += fa * fa; sum_bb += fb * fb; sum_ab += fa * fb;
  }
  s.mae = abs_sum / (double)n;
  s.max_abs = max_abs;
  s.mse = abs_sq / (double)n;
  s.rmse = std::sqrt(s.mse);
  s.mean_rel = rel_sum / (double)n;
  s.max_rel = max_rel;
  s.rel_l2 = std::sqrt(abs_sq) / (std::sqrt(nb) + eps);
  double denom = std::sqrt(na) * std::sqrt(nb);
  s.cosine_sim = denom > eps ? dot / denom : 1.0;
  double dn = (double)n;
  double num = dn * sum_ab - sum_a * sum_b;
  double den = std::sqrt((dn * sum_aa - sum_a * sum_a) * (dn * sum_bb - sum_b * sum_b));
  s.pearson = den > eps ? num / den : 1.0;
  double sim = 1.0 - s.rel_l2;
  if (sim < 0) sim = 0;
  if (sim > 1) sim = 1;
  s.similarity = sim;
  return s;
}

struct AlgoPerfRow {
  int rank = -1, algo = -1, status = -1, math_type = -1;
  std::string name;
  float time_ms = -1.f;
  size_t memory = 0;
};

struct RunResult {
  int algo = -1;
  std::string name, status;
  bool ok = false;
  size_t workspace = 0;
  float time_ms = -1.f;
  bool selected_by_get = false, selected_by_find = false;
  int get_rank = -1, find_rank = -1;
  DiffStats vs_golden;
  std::vector<uint16_t> out_bf16;
};

static void nchw_strides(const Shape4 &s, int *st) {
  st[3] = 1;
  st[2] = s.w;
  st[1] = s.h * s.w;
  st[0] = s.c * s.h * s.w;
}

static void add_bias_nchw_bf16(uint16_t *y, const uint16_t *bias_c, int N,
                               int C, int H, int W) {
  const size_t plane = (size_t)H * (size_t)W;
  for (int n = 0; n < N; ++n) {
    for (int c = 0; c < C; ++c) {
      float b = bf16_bits_to_f32(bias_c[c]);
      uint16_t *p = y + ((size_t)n * (size_t)C + (size_t)c) * plane;
      for (size_t i = 0; i < plane; ++i)
        p[i] = f32_to_bf16_bits(bf16_bits_to_f32(p[i]) + b);
    }
  }
}

static std::vector<uint16_t> gen_bf16(size_t n, std::mt19937 &rng, float scale) {
  std::normal_distribution<float> dist(0.f, scale);
  std::vector<uint16_t> out(n);
  for (size_t i = 0; i < n; ++i)
    out[i] = f32_to_bf16_bits(dist(rng));
  return out;
}

static RunResult run_one(cudnnHandle_t handle, cudnnTensorDescriptor_t xDesc,
                         cudnnFilterDescriptor_t wDesc,
                         cudnnConvolutionDescriptor_t cDesc,
                         cudnnTensorDescriptor_t yDesc, const void *d_x,
                         const void *d_w, void *d_y, void *d_ws, size_t max_ws,
                         cudnnConvolutionFwdAlgo_t algo, const uint16_t *bias,
                         const Shape4 &y_shape) {
  RunResult r;
  r.algo = (int)algo;
  r.name = algo_name(algo);
  size_t out_n = y_shape.numel();

  size_t ws = 0;
  cudnnStatus_t st = cudnnGetConvolutionForwardWorkspaceSize(
      handle, xDesc, wDesc, cDesc, yDesc, algo, &ws);
  if (st != CUDNN_STATUS_SUCCESS) {
    r.ok = false;
    r.status = cudnnGetErrorString(st);
    return r;
  }
  if (ws > max_ws) {
    r.ok = false;
    r.status = "workspace_too_large";
    r.workspace = ws;
    return r;
  }
  r.workspace = ws;

  const float alpha = 1.f, beta = 0.f;
  CHECK_CUDA(cudaMemset(d_y, 0, out_n * sizeof(uint16_t)));
  st = cudnnConvolutionForward(handle, &alpha, xDesc, d_x, wDesc, d_w, cDesc,
                               algo, d_ws, ws, &beta, yDesc, d_y);
  if (st != CUDNN_STATUS_SUCCESS) {
    r.ok = false;
    r.status = cudnnGetErrorString(st);
    return r;
  }
  CHECK_CUDA(cudaDeviceSynchronize());

  CHECK_CUDA(cudaMemset(d_y, 0, out_n * sizeof(uint16_t)));
  cudaEvent_t e0, e1;
  CHECK_CUDA(cudaEventCreate(&e0));
  CHECK_CUDA(cudaEventCreate(&e1));
  CHECK_CUDA(cudaEventRecord(e0));
  CHECK_CUDNN(cudnnConvolutionForward(handle, &alpha, xDesc, d_x, wDesc, d_w,
                                      cDesc, algo, d_ws, ws, &beta, yDesc, d_y));
  CHECK_CUDA(cudaEventRecord(e1));
  CHECK_CUDA(cudaEventSynchronize(e1));
  CHECK_CUDA(cudaEventElapsedTime(&r.time_ms, e0, e1));
  CHECK_CUDA(cudaEventDestroy(e0));
  CHECK_CUDA(cudaEventDestroy(e1));

  r.out_bf16.resize(out_n);
  CHECK_CUDA(cudaMemcpy(r.out_bf16.data(), d_y, out_n * sizeof(uint16_t),
                        cudaMemcpyDeviceToHost));
  add_bias_nchw_bf16(r.out_bf16.data(), bias, y_shape.n, y_shape.c, y_shape.h,
                     y_shape.w);
  r.ok = true;
  r.status = "ok";
  return r;
}

static std::string json_escape(const std::string &s) {
  std::string o;
  for (char c : s) {
    if (c == '"' || c == '\\') o.push_back('\\');
    o.push_back(c);
  }
  return o;
}

static void write_diff(std::ostream &ofs, const DiffStats &d, const std::string &ind) {
  ofs << std::setprecision(17);
  ofs << ind << "\"exact\": " << (d.exact ? "true" : "false") << ",\n";
  ofs << ind << "\"numel\": " << d.numel << ",\n";
  ofs << ind << "\"non_equal\": " << d.non_equal << ",\n";
  ofs << ind << "\"mae\": " << d.mae << ",\n";
  ofs << ind << "\"max_abs\": " << d.max_abs << ",\n";
  ofs << ind << "\"mse\": " << d.mse << ",\n";
  ofs << ind << "\"rmse\": " << d.rmse << ",\n";
  ofs << ind << "\"mean_rel\": " << d.mean_rel << ",\n";
  ofs << ind << "\"max_rel\": " << d.max_rel << ",\n";
  ofs << ind << "\"rel_l2\": " << d.rel_l2 << ",\n";
  ofs << ind << "\"cosine_sim\": " << d.cosine_sim << ",\n";
  ofs << ind << "\"pearson\": " << d.pearson << ",\n";
  ofs << ind << "\"similarity\": " << d.similarity << "\n";
}

static void write_perf(std::ostream &ofs, const std::vector<AlgoPerfRow> &rows) {
  ofs << "  [\n";
  for (size_t i = 0; i < rows.size(); ++i) {
    const auto &r = rows[i];
    ofs << "    {\"rank\":" << r.rank << ",\"algo\":" << r.algo
        << ",\"algo_name\":\"" << r.name << "\",\"status\":" << r.status
        << ",\"time_ms\":" << r.time_ms << ",\"memory\":" << r.memory
        << ",\"math_type\":" << r.math_type << "}"
        << (i + 1 < rows.size() ? "," : "") << "\n";
  }
  ofs << "  ]";
}

} // namespace

int main(int argc, char **argv) {
  // 默认：接近常见 ResNet 中间层的 4D NCHW
  int N = 2, Cin = 64, H = 56, W = 56, Cout = 128, R = 3, S = 3;
  int pad_h = 1, pad_w = 1, stride_h = 1, stride_w = 1;
  unsigned seed = 1234;
  std::string out_json = "summary_cpp.json";
  std::string save_golden_dir;
  std::string baseline_mode = "self";

  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--seed" && i + 1 < argc) {
      seed = (unsigned)std::strtoul(argv[++i], nullptr, 10);
    } else if (a == "--shape" && i + 1 < argc) {
      // N,C,H,W,K,R,S
      sscanf(argv[++i], "%d,%d,%d,%d,%d,%d,%d", &N, &Cin, &H, &W, &Cout, &R, &S);
    } else if (a == "--pad" && i + 1 < argc) {
      sscanf(argv[++i], "%d,%d", &pad_h, &pad_w);
    } else if (a == "--stride" && i + 1 < argc) {
      sscanf(argv[++i], "%d,%d", &stride_h, &stride_w);
    } else if (a == "--out" && i + 1 < argc) {
      out_json = argv[++i];
    } else if (a == "--save-golden" && i + 1 < argc) {
      save_golden_dir = argv[++i];
    } else if (a == "--baseline" && i + 1 < argc) {
      baseline_mode = argv[++i];
    } else if (a == "-h" || a == "--help") {
      std::cout
          << "Usage: " << argv[0] << "\n"
          << "  [--seed 1234] [--shape N,C,H,W,K,R,S]\n"
          << "  [--pad PH,PW] [--stride SH,SW]\n"
          << "  [--out summary.json] [--save-golden DIR]\n";
      return 0;
    }
  }

  int out_h = (H + 2 * pad_h - R) / stride_h + 1;
  int out_w = (W + 2 * pad_w - S) / stride_w + 1;
  Shape4 x_shape{N, Cin, H, W};
  Shape4 y_shape{N, Cout, out_h, out_w};
  Shape4 w_shape{Cout, Cin, R, S}; // KCRS

  std::mt19937 rng(seed);
  auto h_x = gen_bf16(x_shape.numel(), rng, 0.5f);
  auto h_w = gen_bf16(w_shape.numel(), rng, 0.05f);
  auto h_b = gen_bf16((size_t)Cout, rng, 0.01f);

  CHECK_CUDA(cudaSetDevice(0));
  cudaDeviceProp prop;
  CHECK_CUDA(cudaGetDeviceProperties(&prop, 0));
  std::cout << "device: " << prop.name << "\n"
            << "seed=" << seed
            << " shape x=[" << N << "," << Cin << "," << H << "," << W << "]"
            << " w=[" << Cout << "," << Cin << "," << R << "," << S << "]"
            << " y=[" << N << "," << Cout << "," << out_h << "," << out_w << "]"
            << " pad=[" << pad_h << "," << pad_w << "]"
            << " stride=[" << stride_h << "," << stride_w << "]"
            << " dtype=bf16 layout=NCHW\n";

  cudnnHandle_t handle;
  CHECK_CUDNN(cudnnCreate(&handle));
  cudnnTensorDescriptor_t xDesc, yDesc;
  cudnnFilterDescriptor_t wDesc;
  cudnnConvolutionDescriptor_t cDesc;
  CHECK_CUDNN(cudnnCreateTensorDescriptor(&xDesc));
  CHECK_CUDNN(cudnnCreateTensorDescriptor(&yDesc));
  CHECK_CUDNN(cudnnCreateFilterDescriptor(&wDesc));
  CHECK_CUDNN(cudnnCreateConvolutionDescriptor(&cDesc));

  int x_dims[4] = {N, Cin, H, W};
  int y_dims[4] = {N, Cout, out_h, out_w};
  int w_dims[4] = {Cout, Cin, R, S};
  int x_st[4], y_st[4];
  nchw_strides(x_shape, x_st);
  nchw_strides(y_shape, y_st);

  CHECK_CUDNN(cudnnSetTensorNdDescriptor(xDesc, CUDNN_DATA_BFLOAT16, 4, x_dims, x_st));
  CHECK_CUDNN(cudnnSetTensorNdDescriptor(yDesc, CUDNN_DATA_BFLOAT16, 4, y_dims, y_st));
  CHECK_CUDNN(cudnnSetFilterNdDescriptor(wDesc, CUDNN_DATA_BFLOAT16,
                                         CUDNN_TENSOR_NCHW, 4, w_dims));
  int pad[2] = {pad_h, pad_w};
  int stride[2] = {stride_h, stride_w};
  int dil[2] = {1, 1};
  CHECK_CUDNN(cudnnSetConvolutionNdDescriptor(
      cDesc, 2, pad, stride, dil, CUDNN_CROSS_CORRELATION, CUDNN_DATA_FLOAT));
  CHECK_CUDNN(cudnnSetConvolutionGroupCount(cDesc, 1));
  CHECK_CUDNN(cudnnSetConvolutionMathType(cDesc, CUDNN_DEFAULT_MATH));

  void *d_x = nullptr, *d_w = nullptr, *d_y = nullptr, *d_ws = nullptr;
  CHECK_CUDA(cudaMalloc(&d_x, x_shape.numel() * 2));
  CHECK_CUDA(cudaMalloc(&d_w, w_shape.numel() * 2));
  CHECK_CUDA(cudaMalloc(&d_y, y_shape.numel() * 2));
  const size_t max_ws = 512ull << 20;
  CHECK_CUDA(cudaMalloc(&d_ws, max_ws));
  CHECK_CUDA(cudaMemcpy(d_x, h_x.data(), x_shape.numel() * 2, cudaMemcpyHostToDevice));
  CHECK_CUDA(cudaMemcpy(d_w, h_w.data(), w_shape.numel() * 2, cudaMemcpyHostToDevice));

  // Get_v7
  std::vector<AlgoPerfRow> get_rows;
  int get_selected = -1;
  {
    int returned = 0;
    std::vector<cudnnConvolutionFwdAlgoPerf_t> perf(CUDNN_CONVOLUTION_FWD_ALGO_COUNT);
    cudnnStatus_t gst = cudnnGetConvolutionForwardAlgorithm_v7(
        handle, xDesc, wDesc, cDesc, yDesc, CUDNN_CONVOLUTION_FWD_ALGO_COUNT,
        &returned, perf.data());
    std::cout << "\n=== Get_v7 ===\n";
    if (gst == CUDNN_STATUS_SUCCESS) {
      for (int i = 0; i < returned; ++i) {
        AlgoPerfRow row;
        row.rank = i;
        row.algo = (int)perf[i].algo;
        row.name = algo_name(perf[i].algo);
        row.status = (int)perf[i].status;
        row.time_ms = perf[i].time;
        row.memory = perf[i].memory;
        row.math_type = (int)perf[i].mathType;
        get_rows.push_back(row);
        std::cout << "  rank" << i << " algo=" << row.algo << " (" << row.name
                  << ") status=" << row.status << "\n";
        if (get_selected < 0 && row.status == 0)
          get_selected = row.algo;
      }
      std::cout << "  => Get pick algo=" << get_selected << "\n";
    } else {
      std::cout << "  FAILED: " << cudnnGetErrorString(gst) << "\n";
    }
  }

  // FindEx
  std::vector<AlgoPerfRow> find_rows;
  int find_selected = -1;
  {
    int returned = 0;
    std::vector<cudnnConvolutionFwdAlgoPerf_t> perf(CUDNN_CONVOLUTION_FWD_ALGO_COUNT);
    CHECK_CUDNN(cudnnFindConvolutionForwardAlgorithmEx(
        handle, xDesc, d_x, wDesc, d_w, cDesc, yDesc, d_y,
        CUDNN_CONVOLUTION_FWD_ALGO_COUNT, &returned, perf.data(), d_ws, max_ws));
    std::cout << "\n=== FindEx ===\n";
    for (int i = 0; i < returned; ++i) {
      AlgoPerfRow row;
      row.rank = i;
      row.algo = (int)perf[i].algo;
      row.name = algo_name(perf[i].algo);
      row.status = (int)perf[i].status;
      row.time_ms = perf[i].time;
      row.memory = perf[i].memory;
      row.math_type = (int)perf[i].mathType;
      find_rows.push_back(row);
      std::cout << "  rank" << i << " algo=" << row.algo << " (" << row.name
                << ") status=" << row.status << " time=" << row.time_ms << "\n";
      if (find_selected < 0 && row.status == 0)
        find_selected = row.algo;
    }
  }

  std::vector<RunResult> runs;
  std::cout << "\n=== run ALL FWD algos ===\n";
  for (int a = 0; a < (int)CUDNN_CONVOLUTION_FWD_ALGO_COUNT; ++a) {
    auto r = run_one(handle, xDesc, wDesc, cDesc, yDesc, d_x, d_w, d_y, d_ws,
                     max_ws, (cudnnConvolutionFwdAlgo_t)a, h_b.data(), y_shape);
    r.selected_by_get = (r.algo == get_selected);
    r.selected_by_find = (r.algo == find_selected);
    int get_st = -1, find_st = -1;
    for (const auto &g : get_rows)
      if (g.algo == r.algo) { r.get_rank = g.rank; get_st = g.status; break; }
    for (const auto &f : find_rows)
      if (f.algo == r.algo) { r.find_rank = f.rank; find_st = f.status; break; }
    if (!r.ok) {
      std::ostringstream oss;
      oss << r.status;
      if (get_st > 0) oss << "; Get.status=" << get_st;
      if (find_st > 0) oss << "; Find.status=" << find_st;
      r.status = std::string("不支持/报错: ") + oss.str();
      std::cout << "algo" << r.algo << " " << r.name << " ok=0 " << r.status << "\n";
    } else {
      std::cout << "algo" << r.algo << " " << r.name << " ok=1"
                << " get_sel=" << r.selected_by_get
                << " find_sel=" << r.selected_by_find
                << " time_ms=" << r.time_ms << "\n";
    }
    runs.push_back(std::move(r));
  }

  // baseline=self
  int baseline_algo = -1;
  const RunResult *bref = nullptr;
  auto find_ok = [&](int algo) -> const RunResult * {
    for (const auto &r : runs)
      if (r.ok && r.algo == algo) return &r;
    return nullptr;
  };
  if (find_ok(get_selected)) baseline_algo = get_selected;
  else if (find_ok(find_selected)) baseline_algo = find_selected;
  else {
    for (const auto &r : runs)
      if (r.ok) { baseline_algo = r.algo; break; }
  }
  bref = find_ok(baseline_algo);
  if (!bref) {
    std::cerr << "no supported algo\n";
    return 1;
  }
  std::cout << "\n=== baseline=self ref_algo=" << baseline_algo << " ("
            << algo_name((cudnnConvolutionFwdAlgo_t)baseline_algo) << ") ===\n";
  bool all_exact = true;
  int supported_n = 0;
  for (auto &r : runs) {
    if (!r.ok) continue;
    ++supported_n;
    r.vs_golden = diff_bf16(r.out_bf16.data(), bref->out_bf16.data(),
                            r.out_bf16.size());
    if (!r.vs_golden.exact) all_exact = false;
    std::cout << "algo" << r.algo << " vs ref: exact=" << r.vs_golden.exact
              << " non_eq=" << r.vs_golden.non_equal
              << " max_abs=" << r.vs_golden.max_abs << "\n";
  }
  std::cout << "\n=== verdict: supported=" << supported_n
            << " all_exact_to_baseline=" << all_exact << " ===\n";

  std::cout << "\n=== pairwise (supported) ===\n";
  for (size_t i = 0; i < runs.size(); ++i) {
    if (!runs[i].ok) continue;
    for (size_t j = i + 1; j < runs.size(); ++j) {
      if (!runs[j].ok) continue;
      auto d = diff_bf16(runs[i].out_bf16.data(), runs[j].out_bf16.data(),
                         runs[i].out_bf16.size());
      std::cout << "algo" << runs[i].algo << " vs algo" << runs[j].algo
                << ": exact=" << d.exact << " non_eq=" << d.non_equal
                << " max_abs=" << d.max_abs << "\n";
    }
  }

  if (!save_golden_dir.empty()) {
    std::string cmd = "mkdir -p \"" + save_golden_dir + "\"";
    std::system(cmd.c_str());
    auto dump = [&](const std::string &name, const std::vector<uint16_t> &v) {
      std::ofstream ofs(save_golden_dir + "/" + name, std::ios::binary);
      ofs.write(reinterpret_cast<const char *>(v.data()),
                (std::streamsize)(v.size() * 2));
    };
    dump("x.bf16.bin", h_x);
    dump("weight.bf16.bin", h_w);
    dump("bias.bf16.bin", h_b);
    dump("out_golden.bf16.bin", bref->out_bf16);
    std::ofstream meta(save_golden_dir + "/meta_note.txt");
    meta << "device=" << prop.name << "\nseed=" << seed
         << "\nshape=N" << N << "C" << Cin << "H" << H << "W" << W
         << "K" << Cout << "R" << R << "S" << S
         << "\nbaseline_algo=" << baseline_algo << "\n";
    std::cout << "saved golden -> " << save_golden_dir << "\n";
  }

  // JSON
  {
    std::ofstream ofs(out_json);
    ofs << "{\n";
    ofs << "  \"device\": \"" << json_escape(prop.name) << "\",\n";
    ofs << "  \"dtype\": \"bfloat16\",\n";
    ofs << "  \"layout\": \"NCHW\",\n";
    ofs << "  \"seed\": " << seed << ",\n";
    ofs << "  \"shape\": {\"n\":" << N << ",\"c\":" << Cin << ",\"h\":" << H
        << ",\"w\":" << W << ",\"k\":" << Cout << ",\"r\":" << R
        << ",\"s\":" << S << ",\"out_h\":" << out_h << ",\"out_w\":" << out_w
        << ",\"pad_h\":" << pad_h << ",\"pad_w\":" << pad_w
        << ",\"stride_h\":" << stride_h << ",\"stride_w\":" << stride_w
        << "},\n";
    ofs << "  \"baseline_mode\": \"" << baseline_mode << "\",\n";
    ofs << "  \"baseline_algo\": " << baseline_algo << ",\n";
    ofs << "  \"baseline_algo_name\": \""
        << algo_name((cudnnConvolutionFwdAlgo_t)baseline_algo) << "\",\n";
    ofs << "  \"all_supported_algos_exact_to_baseline\": "
        << (all_exact ? "true" : "false") << ",\n";
    ofs << "  \"get_selected_algo\": " << get_selected << ",\n";
    ofs << "  \"get_selected_algo_name\": \""
        << (get_selected >= 0 ? algo_name((cudnnConvolutionFwdAlgo_t)get_selected) : "")
        << "\",\n";
    ofs << "  \"find_selected_algo\": " << find_selected << ",\n";
    ofs << "  \"find_selected_algo_name\": \""
        << (find_selected >= 0 ? algo_name((cudnnConvolutionFwdAlgo_t)find_selected) : "")
        << "\",\n";
    ofs << "  \"get_results\": "; write_perf(ofs, get_rows); ofs << ",\n";
    ofs << "  \"find_results\": "; write_perf(ofs, find_rows); ofs << ",\n";
    ofs << "  \"runs\": [\n";
    for (size_t i = 0; i < runs.size(); ++i) {
      const auto &r = runs[i];
      ofs << "    {\"algo\":" << r.algo << ",\"algo_name\":\"" << r.name
          << "\",\"ok\":" << (r.ok ? "true" : "false")
          << ",\"status\":\"" << json_escape(r.status) << "\""
          << ",\"workspace\":" << r.workspace
          << ",\"time_ms\":" << r.time_ms
          << ",\"selected_by_get\":" << (r.selected_by_get ? "true" : "false")
          << ",\"selected_by_find\":" << (r.selected_by_find ? "true" : "false")
          << ",\"is_baseline\":" << (r.ok && r.algo == baseline_algo ? "true" : "false")
          << ",\"get_rank\":" << r.get_rank << ",\"find_rank\":" << r.find_rank
          << ",\"vs_golden\":{\n";
      write_diff(ofs, r.vs_golden, "      ");
      ofs << "    }}" << (i + 1 < runs.size() ? "," : "") << "\n";
    }
    ofs << "  ],\n  \"pairwise\": [\n";
    bool first = true;
    for (size_t i = 0; i < runs.size(); ++i) {
      if (!runs[i].ok) continue;
      for (size_t j = i + 1; j < runs.size(); ++j) {
        if (!runs[j].ok) continue;
        auto d = diff_bf16(runs[i].out_bf16.data(), runs[j].out_bf16.data(),
                           runs[i].out_bf16.size());
        if (!first) ofs << ",\n";
        first = false;
        ofs << "    {\"a\":\"algo" << runs[i].algo << "_" << runs[i].name
            << "\",\"b\":\"algo" << runs[j].algo << "_" << runs[j].name
            << "\",\"a_algo\":" << runs[i].algo
            << ",\"b_algo\":" << runs[j].algo << ",\n";
        write_diff(ofs, d, "     ");
        ofs << "    }";
      }
    }
    ofs << "\n  ]\n}\n";
  }
  std::cout << "wrote " << out_json << "\n";

  CHECK_CUDA(cudaFree(d_x));
  CHECK_CUDA(cudaFree(d_w));
  CHECK_CUDA(cudaFree(d_y));
  CHECK_CUDA(cudaFree(d_ws));
  cudnnDestroyTensorDescriptor(xDesc);
  cudnnDestroyTensorDescriptor(yDesc);
  cudnnDestroyFilterDescriptor(wDesc);
  cudnnDestroyConvolutionDescriptor(cDesc);
  cudnnDestroy(handle);
  return 0;
}
