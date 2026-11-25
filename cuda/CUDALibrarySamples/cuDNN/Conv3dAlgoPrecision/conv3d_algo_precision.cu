/*
 * Load NCDHW golden tensors and call cudnnConvolutionForward for each FWD algo.
 * Record Get / Find selection, sweep supported algos, and compare precision.
 *
 * Expect golden_dir with: padded.bf16.bin, weight.bf16.bin, bias.bf16.bin,
 * and optional out_golden.bf16.bin / meta.json.
 *
 * Usage:
 *   ./conv3d_algo_precision [golden_dir] [--algos all] [--out summary.json]
 *
 * Convert summary with: python3 export_excel.py summary.json -o report.xlsx
 */

#include <cudnn.h>
#include <cuda_runtime.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#define CHECK_CUDA(expr)                                                       \
  do {                                                                         \
    cudaError_t _e = (expr);                                                   \
    if (_e != cudaSuccess) {                                                   \
      std::cerr << "CUDA error " << __FILE__ << ":" << __LINE__ << " "         \
                << cudaGetErrorString(_e) << std::endl;                        \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

#define CHECK_CUDNN(expr)                                                      \
  do {                                                                         \
    cudnnStatus_t _s = (expr);                                                 \
    if (_s != CUDNN_STATUS_SUCCESS) {                                          \
      std::cerr << "cuDNN error " << __FILE__ << ":" << __LINE__ << " "        \
                << cudnnGetErrorString(_s) << std::endl;                       \
      std::exit(1);                                                            \
    }                                                                          \
  } while (0)

namespace {

struct Shape5 {
  int n, c, d, h, w;
  size_t numel() const {
    return (size_t)n * (size_t)c * (size_t)d * (size_t)h * (size_t)w;
  }
};

struct AlgoPerfRow {
  int rank = -1;
  int algo = -1;
  std::string name;
  int status = -1;
  float time_ms = -1.f;
  size_t memory = 0;
  int math_type = -1;
  bool from_get = false;
  bool from_find = false;
};

static const char *algo_name(cudnnConvolutionFwdAlgo_t a) {
  switch ((int)a) {
  case 0:
    return "IMPLICIT_GEMM";
  case 1:
    return "IMPLICIT_PRECOMP_GEMM";
  case 2:
    return "GEMM";
  case 3:
    return "DIRECT";
  case 4:
    return "FFT";
  case 5:
    return "FFT_TILING";
  case 6:
    return "WINOGRAD";
  case 7:
    return "WINOGRAD_NONFUSED";
  default:
    return "UNKNOWN";
  }
}

static std::vector<uint8_t> read_file(const std::string &path) {
  std::ifstream ifs(path, std::ios::binary);
  if (!ifs) {
    std::cerr << "failed to open " << path << std::endl;
    std::exit(1);
  }
  ifs.seekg(0, std::ios::end);
  size_t n = (size_t)ifs.tellg();
  ifs.seekg(0, std::ios::beg);
  std::vector<uint8_t> buf(n);
  if (n)
    ifs.read(reinterpret_cast<char *>(buf.data()), (std::streamsize)n);
  return buf;
}

static float bf16_bits_to_f32(uint16_t bits) {
  uint32_t u = ((uint32_t)bits) << 16;
  float f;
  std::memcpy(&f, &u, sizeof(f));
  return f;
}

struct DiffStats {
  bool exact = true;
  size_t numel = 0;
  size_t non_equal = 0;
  double mae = 0.0;          // mean abs error
  double max_abs = 0.0;      // max abs error
  double mse = 0.0;
  double rmse = 0.0;
  double mean_rel = 0.0;     // mean |a-b|/(|b|+eps)
  double max_rel = 0.0;      // max relative error
  double rel_l2 = 0.0;       // ||a-b||_2 / ||b||_2
  double cosine_sim = 0.0;   // cosine similarity
  double pearson = 0.0;      // pearson correlation
  double similarity = 0.0;   // 1 - rel_l2, clipped to [0,1]
};

static DiffStats diff_bf16(const uint16_t *a, const uint16_t *b, size_t n) {
  DiffStats s;
  s.numel = n;
  if (n == 0)
    return s;

  const double eps = 1e-12;
  double abs_sum = 0.0;
  double abs_sq = 0.0;
  double rel_sum = 0.0;
  double max_abs = 0.0;
  double max_rel = 0.0;
  double dot = 0.0;
  double na = 0.0;
  double nb = 0.0;
  double sum_a = 0.0, sum_b = 0.0, sum_aa = 0.0, sum_bb = 0.0, sum_ab = 0.0;

  for (size_t i = 0; i < n; ++i) {
    if (a[i] != b[i]) {
      s.exact = false;
      ++s.non_equal;
    }
    double fa = bf16_bits_to_f32(a[i]);
    double fb = bf16_bits_to_f32(b[i]);
    double d = std::fabs(fa - fb);
    if (d > max_abs)
      max_abs = d;
    abs_sum += d;
    abs_sq += d * d;
    double rel = d / (std::fabs(fb) + eps);
    rel_sum += rel;
    if (rel > max_rel)
      max_rel = rel;

    dot += fa * fb;
    na += fa * fa;
    nb += fb * fb;
    sum_a += fa;
    sum_b += fb;
    sum_aa += fa * fa;
    sum_bb += fb * fb;
    sum_ab += fa * fb;
  }

  s.mae = abs_sum / (double)n;
  s.max_abs = max_abs;
  s.mse = abs_sq / (double)n;
  s.rmse = std::sqrt(s.mse);
  s.mean_rel = rel_sum / (double)n;
  s.max_rel = max_rel;
  s.rel_l2 = std::sqrt(abs_sq) / (std::sqrt(nb) + eps);
  double denom = std::sqrt(na) * std::sqrt(nb);
  s.cosine_sim = denom > eps ? (dot / denom) : 1.0;

  double dn = (double)n;
  double num = dn * sum_ab - sum_a * sum_b;
  double den = std::sqrt((dn * sum_aa - sum_a * sum_a) *
                         (dn * sum_bb - sum_b * sum_b));
  s.pearson = den > eps ? (num / den) : 1.0;
  {
    double sim = 1.0 - s.rel_l2;
    if (sim < 0.0)
      sim = 0.0;
    if (sim > 1.0)
      sim = 1.0;
    s.similarity = sim;
  }
  return s;
}

struct RunResult {
  int algo = -1;
  std::string name;
  bool ok = false;
  std::string status;
  size_t workspace = 0;
  float time_ms = -1.f;
  bool selected_by_get = false;
  bool selected_by_find = false;
  int get_rank = -1;
  int find_rank = -1;
  DiffStats vs_golden;
  std::vector<uint16_t> out_bf16;
};

static void ncdhw_strides(const Shape5 &s, int *st) {
  st[4] = 1;
  st[3] = s.w;
  st[2] = s.h * s.w;
  st[1] = s.d * s.h * s.w;
  st[0] = s.c * s.d * s.h * s.w;
}

static void add_bias_ncdhw_bf16(uint16_t *y, const uint16_t *bias_c, int N,
                                int C, int D, int H, int W) {
  const size_t plane = (size_t)D * (size_t)H * (size_t)W;
  for (int n = 0; n < N; ++n) {
    for (int c = 0; c < C; ++c) {
      float b = bf16_bits_to_f32(bias_c[c]);
      uint16_t *p = y + ((size_t)n * (size_t)C + (size_t)c) * plane;
      for (size_t i = 0; i < plane; ++i) {
        float v = bf16_bits_to_f32(p[i]) + b;
        uint32_t u;
        std::memcpy(&u, &v, sizeof(u));
        uint32_t rounding_bias = ((u >> 16) & 1u) + 0x7FFFu;
        p[i] = (uint16_t)((u + rounding_bias) >> 16);
      }
    }
  }
}

static RunResult run_one_algo(cudnnHandle_t handle, cudnnTensorDescriptor_t xDesc,
                              cudnnFilterDescriptor_t wDesc,
                              cudnnConvolutionDescriptor_t cDesc,
                              cudnnTensorDescriptor_t yDesc, const void *d_x,
                              const void *d_w, void *d_y, void *d_ws,
                              size_t max_ws, cudnnConvolutionFwdAlgo_t algo,
                              const uint16_t *bias_c, const uint16_t *golden,
                              const Shape5 &y_shape) {
  RunResult r;
  r.algo = (int)algo;
  r.name = algo_name(algo);
  const size_t out_n = y_shape.numel();

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

  CHECK_CUDA(cudaMemset(d_y, 0, out_n * sizeof(uint16_t)));
  const float alpha = 1.f, beta = 0.f;

  st = cudnnConvolutionForward(handle, &alpha, xDesc, d_x, wDesc, d_w, cDesc,
                               algo, d_ws, ws, &beta, yDesc, d_y);
  if (st != CUDNN_STATUS_SUCCESS) {
    r.ok = false;
    r.status = cudnnGetErrorString(st);
    return r;
  }
  CHECK_CUDA(cudaDeviceSynchronize());

  CHECK_CUDA(cudaMemset(d_y, 0, out_n * sizeof(uint16_t)));
  cudaEvent_t ev0, ev1;
  CHECK_CUDA(cudaEventCreate(&ev0));
  CHECK_CUDA(cudaEventCreate(&ev1));
  CHECK_CUDA(cudaEventRecord(ev0));
  CHECK_CUDNN(cudnnConvolutionForward(handle, &alpha, xDesc, d_x, wDesc, d_w,
                                      cDesc, algo, d_ws, ws, &beta, yDesc,
                                      d_y));
  CHECK_CUDA(cudaEventRecord(ev1));
  CHECK_CUDA(cudaEventSynchronize(ev1));
  CHECK_CUDA(cudaEventElapsedTime(&r.time_ms, ev0, ev1));
  CHECK_CUDA(cudaEventDestroy(ev0));
  CHECK_CUDA(cudaEventDestroy(ev1));

  r.out_bf16.resize(out_n);
  CHECK_CUDA(cudaMemcpy(r.out_bf16.data(), d_y, out_n * sizeof(uint16_t),
                        cudaMemcpyDeviceToHost));
  add_bias_ncdhw_bf16(r.out_bf16.data(), bias_c, y_shape.n, y_shape.c,
                      y_shape.d, y_shape.h, y_shape.w);
  r.vs_golden = diff_bf16(r.out_bf16.data(), golden, out_n);
  r.ok = true;
  r.status = "ok";
  return r;
}

static std::vector<int> parse_algos(const std::string &s) {
  std::vector<int> out;
  std::stringstream ss(s);
  std::string item;
  while (std::getline(ss, item, ',')) {
    if (item.empty())
      continue;
    out.push_back(std::atoi(item.c_str()));
  }
  return out;
}

static std::string json_escape(const std::string &s) {
  std::string o;
  for (char c : s) {
    if (c == '"' || c == '\\')
      o.push_back('\\');
    o.push_back(c);
  }
  return o;
}

static void write_diff_json(std::ostream &ofs, const DiffStats &d,
                            const std::string &indent) {
  ofs << indent << "\"exact\": " << (d.exact ? "true" : "false") << ",\n";
  ofs << indent << "\"numel\": " << d.numel << ",\n";
  ofs << indent << "\"non_equal\": " << d.non_equal << ",\n";
  ofs << std::setprecision(17);
  ofs << indent << "\"mae\": " << d.mae << ",\n";
  ofs << indent << "\"max_abs\": " << d.max_abs << ",\n";
  ofs << indent << "\"mse\": " << d.mse << ",\n";
  ofs << indent << "\"rmse\": " << d.rmse << ",\n";
  ofs << indent << "\"mean_rel\": " << d.mean_rel << ",\n";
  ofs << indent << "\"max_rel\": " << d.max_rel << ",\n";
  ofs << indent << "\"rel_l2\": " << d.rel_l2 << ",\n";
  ofs << indent << "\"cosine_sim\": " << d.cosine_sim << ",\n";
  ofs << indent << "\"pearson\": " << d.pearson << ",\n";
  ofs << indent << "\"similarity\": " << d.similarity << "\n";
}

static void write_perf_array(std::ostream &ofs, const std::vector<AlgoPerfRow> &rows) {
  ofs << "  [\n";
  for (size_t i = 0; i < rows.size(); ++i) {
    const auto &r = rows[i];
    ofs << "    {\n";
    ofs << "      \"rank\": " << r.rank << ",\n";
    ofs << "      \"algo\": " << r.algo << ",\n";
    ofs << "      \"algo_name\": \"" << r.name << "\",\n";
    ofs << "      \"status\": " << r.status << ",\n";
    ofs << "      \"time_ms\": " << r.time_ms << ",\n";
    ofs << "      \"memory\": " << r.memory << ",\n";
    ofs << "      \"math_type\": " << r.math_type << "\n";
    ofs << "    }" << (i + 1 < rows.size() ? "," : "") << "\n";
  }
  ofs << "  ]";
}

static bool write_bin_copy(const std::string &src, const std::string &dst,
                           bool required = true) {
  std::ifstream ifs(src, std::ios::binary);
  if (!ifs) {
    if (required)
      std::cerr << "missing required file: " << src << std::endl;
    return false;
  }
  ifs.seekg(0, std::ios::end);
  size_t n = (size_t)ifs.tellg();
  ifs.seekg(0, std::ios::beg);
  std::vector<uint8_t> buf(n);
  if (n)
    ifs.read(reinterpret_cast<char *>(buf.data()), (std::streamsize)n);
  std::ofstream ofs(dst, std::ios::binary);
  if (!ofs)
    return false;
  ofs.write(reinterpret_cast<const char *>(buf.data()),
            (std::streamsize)buf.size());
  return true;
}

static void write_summary_json(const std::string &path,
                               const std::vector<RunResult> &runs,
                               const std::vector<AlgoPerfRow> &get_rows,
                               const std::vector<AlgoPerfRow> &find_rows,
                               int get_selected, int get_prefer_fastest,
                               int find_selected, const std::string &golden_dir,
                               const std::string &device_name,
                               const std::string &baseline_mode,
                               int baseline_algo,
                               const std::string &save_golden_dir,
                               bool all_supported_exact) {
  std::ofstream ofs(path);
  ofs << "{\n";
  ofs << "  \"golden_dir\": \"" << json_escape(golden_dir) << "\",\n";
  ofs << "  \"device\": \"" << json_escape(device_name) << "\",\n";
  ofs << "  \"dtype\": \"bfloat16\",\n";
  ofs << "  \"baseline_mode\": \"" << json_escape(baseline_mode) << "\",\n";
  ofs << "  \"baseline_algo\": " << baseline_algo << ",\n";
  ofs << "  \"baseline_algo_name\": \""
      << (baseline_algo >= 0
              ? algo_name((cudnnConvolutionFwdAlgo_t)baseline_algo)
              : "")
      << "\",\n";
  ofs << "  \"save_golden_dir\": \"" << json_escape(save_golden_dir) << "\",\n";
  ofs << "  \"all_supported_algos_exact_to_baseline\": "
      << (all_supported_exact ? "true" : "false") << ",\n";
  ofs << "  \"note\": \"baseline=file: compare to golden/out; "
         "baseline=self: compare to chosen local algo output "
         "(for NV consistency check)\",\n";
  ofs << "  \"get_selected_algo\": " << get_selected << ",\n";
  ofs << "  \"get_selected_algo_name\": \""
      << (get_selected >= 0
              ? algo_name((cudnnConvolutionFwdAlgo_t)get_selected)
              : "")
      << "\",\n";
  ofs << "  \"get_prefer_fastest_algo\": " << get_prefer_fastest << ",\n";
  ofs << "  \"get_prefer_fastest_algo_name\": \""
      << (get_prefer_fastest >= 0
              ? algo_name((cudnnConvolutionFwdAlgo_t)get_prefer_fastest)
              : "")
      << "\",\n";
  ofs << "  \"find_selected_algo\": " << find_selected << ",\n";
  ofs << "  \"find_selected_algo_name\": \""
      << (find_selected >= 0
              ? algo_name((cudnnConvolutionFwdAlgo_t)find_selected)
              : "")
      << "\",\n";
  ofs << "  \"get_results\": ";
  write_perf_array(ofs, get_rows);
  ofs << ",\n";
  ofs << "  \"find_results\": ";
  write_perf_array(ofs, find_rows);
  ofs << ",\n";
  ofs << "  \"runs\": [\n";
  for (size_t i = 0; i < runs.size(); ++i) {
    const auto &r = runs[i];
    ofs << "    {\n";
    ofs << "      \"algo\": " << r.algo << ",\n";
    ofs << "      \"algo_name\": \"" << r.name << "\",\n";
    ofs << "      \"ok\": " << (r.ok ? "true" : "false") << ",\n";
    ofs << "      \"status\": \"" << json_escape(r.status) << "\",\n";
    ofs << "      \"workspace\": " << r.workspace << ",\n";
    ofs << "      \"time_ms\": " << r.time_ms << ",\n";
    ofs << "      \"selected_by_get\": "
        << (r.selected_by_get ? "true" : "false") << ",\n";
    ofs << "      \"selected_by_find\": "
        << (r.selected_by_find ? "true" : "false") << ",\n";
    ofs << "      \"is_baseline\": "
        << (r.algo == baseline_algo && r.ok ? "true" : "false") << ",\n";
    ofs << "      \"get_rank\": " << r.get_rank << ",\n";
    ofs << "      \"find_rank\": " << r.find_rank << ",\n";
    ofs << "      \"vs_golden\": {\n";
    write_diff_json(ofs, r.vs_golden, "        ");
    ofs << "      }\n";
    ofs << "    }" << (i + 1 < runs.size() ? "," : "") << "\n";
  }
  ofs << "  ],\n";
  ofs << "  \"pairwise\": [\n";
  bool first = true;
  for (size_t i = 0; i < runs.size(); ++i) {
    if (!runs[i].ok)
      continue;
    for (size_t j = i + 1; j < runs.size(); ++j) {
      if (!runs[j].ok)
        continue;
      auto d = diff_bf16(runs[i].out_bf16.data(), runs[j].out_bf16.data(),
                         runs[i].out_bf16.size());
      if (!first)
        ofs << ",\n";
      first = false;
      ofs << "    {\n";
      ofs << "      \"a\": \"algo" << runs[i].algo << "_" << runs[i].name
          << "\",\n";
      ofs << "      \"b\": \"algo" << runs[j].algo << "_" << runs[j].name
          << "\",\n";
      ofs << "      \"a_algo\": " << runs[i].algo << ",\n";
      ofs << "      \"b_algo\": " << runs[j].algo << ",\n";
      write_diff_json(ofs, d, "      ");
      ofs << "    }";
    }
  }
  ofs << "\n  ]\n";
  ofs << "}\n";
}

} // namespace

int main(int argc, char **argv) {
  std::string golden_dir = "../golden";
  // all: 扫全部 FWD algo（0..COUNT-1），不支持的也记录报错
  std::string algos_str = "all";
  std::string out_json = "summary_cpp.json";
  // file: 对比 golden/out；self: 用本机某成功算法输出作基线（NV 一致性检查）
  std::string baseline_mode = "file";
  std::string baseline_algo_str = "auto"; // auto|N
  std::string save_golden_dir;            // 非空则落盘 NV/本机 golden

  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--algos" && i + 1 < argc) {
      algos_str = argv[++i];
    } else if (a == "--out" && i + 1 < argc) {
      out_json = argv[++i];
    } else if (a == "--baseline" && i + 1 < argc) {
      baseline_mode = argv[++i];
    } else if (a == "--ref-algo" && i + 1 < argc) {
      baseline_algo_str = argv[++i];
    } else if (a == "--save-golden" && i + 1 < argc) {
      save_golden_dir = argv[++i];
    } else if (a == "--find") {
      // kept for backward compat; get+find always run now
    } else if (a == "-h" || a == "--help") {
      std::cout
          << "Usage: " << argv[0]
          << " [golden_dir] [--algos all|auto|0,1,4] [--out summary.json]\n"
          << "          [--baseline file|self] [--ref-algo auto|N] "
             "[--save-golden DIR]\n"
          << "  --algos all        run every FWD algo (default)\n"
          << "  --baseline file    compare to golden/out_*.bin (default)\n"
          << "  --baseline self    use local ref algo output as golden "
             "(NV consistency)\n"
          << "  --ref-algo auto|N  ref for baseline=self "
             "(auto=Get_v7 else Find else first ok)\n"
          << "  --save-golden DIR  save inputs+ref out as a new golden pack\n";
      return 0;
    } else if (a[0] != '-') {
      golden_dir = a;
    }
  }

  Shape5 x_shape{1, 96, 3, 274, 274};
  Shape5 w_shape{96, 96, 3, 3, 3};
  Shape5 y_shape{1, 96, 1, 272, 272};

  auto padded = read_file(golden_dir + "/padded.bf16.bin");
  auto weight = read_file(golden_dir + "/weight.bf16.bin");
  auto bias = read_file(golden_dir + "/bias.bf16.bin");
  auto golden = read_file(golden_dir + "/out_golden.bf16.bin");

  if (padded.size() != x_shape.numel() * 2 ||
      weight.size() != w_shape.numel() * 2 || bias.size() != 96 * 2 ||
      golden.size() != y_shape.numel() * 2) {
    std::cerr << "golden bin size mismatch under " << golden_dir << std::endl;
    return 1;
  }

  const uint16_t *h_x = reinterpret_cast<const uint16_t *>(padded.data());
  const uint16_t *h_w = reinterpret_cast<const uint16_t *>(weight.data());
  const uint16_t *h_b = reinterpret_cast<const uint16_t *>(bias.data());
  const uint16_t *h_g = reinterpret_cast<const uint16_t *>(golden.data());

  CHECK_CUDA(cudaSetDevice(0));
  cudaDeviceProp prop;
  CHECK_CUDA(cudaGetDeviceProperties(&prop, 0));
  std::cout << "device: " << prop.name << std::endl;
  std::cout << "golden: " << golden_dir << std::endl;

  cudnnHandle_t handle;
  CHECK_CUDNN(cudnnCreate(&handle));

  cudnnTensorDescriptor_t xDesc, yDesc;
  cudnnFilterDescriptor_t wDesc;
  cudnnConvolutionDescriptor_t cDesc;
  CHECK_CUDNN(cudnnCreateTensorDescriptor(&xDesc));
  CHECK_CUDNN(cudnnCreateTensorDescriptor(&yDesc));
  CHECK_CUDNN(cudnnCreateFilterDescriptor(&wDesc));
  CHECK_CUDNN(cudnnCreateConvolutionDescriptor(&cDesc));

  int x_dims[5] = {x_shape.n, x_shape.c, x_shape.d, x_shape.h, x_shape.w};
  int y_dims[5] = {y_shape.n, y_shape.c, y_shape.d, y_shape.h, y_shape.w};
  int w_dims[5] = {w_shape.n, w_shape.c, w_shape.d, w_shape.h, w_shape.w};
  int x_st[5], y_st[5];
  ncdhw_strides(x_shape, x_st);
  ncdhw_strides(y_shape, y_st);

  CHECK_CUDNN(cudnnSetTensorNdDescriptor(xDesc, CUDNN_DATA_BFLOAT16, 5, x_dims,
                                         x_st));
  CHECK_CUDNN(cudnnSetTensorNdDescriptor(yDesc, CUDNN_DATA_BFLOAT16, 5, y_dims,
                                         y_st));
  CHECK_CUDNN(cudnnSetFilterNdDescriptor(wDesc, CUDNN_DATA_BFLOAT16,
                                         CUDNN_TENSOR_NCHW, 5, w_dims));

  int pad[3] = {0, 0, 0};
  int stride[3] = {1, 1, 1};
  int dilation[3] = {1, 1, 1};
  CHECK_CUDNN(cudnnSetConvolutionNdDescriptor(
      cDesc, 3, pad, stride, dilation, CUDNN_CROSS_CORRELATION,
      CUDNN_DATA_FLOAT));
  CHECK_CUDNN(cudnnSetConvolutionGroupCount(cDesc, 1));
  CHECK_CUDNN(cudnnSetConvolutionMathType(cDesc, CUDNN_DEFAULT_MATH));

  void *d_x = nullptr, *d_w = nullptr, *d_y = nullptr, *d_ws = nullptr;
  CHECK_CUDA(cudaMalloc(&d_x, x_shape.numel() * sizeof(uint16_t)));
  CHECK_CUDA(cudaMalloc(&d_w, w_shape.numel() * sizeof(uint16_t)));
  CHECK_CUDA(cudaMalloc(&d_y, y_shape.numel() * sizeof(uint16_t)));
  const size_t max_ws = 256ull * 1024ull * 1024ull;
  CHECK_CUDA(cudaMalloc(&d_ws, max_ws));
  CHECK_CUDA(cudaMemcpy(d_x, h_x, x_shape.numel() * sizeof(uint16_t),
                        cudaMemcpyHostToDevice));
  CHECK_CUDA(cudaMemcpy(d_w, h_w, w_shape.numel() * sizeof(uint16_t),
                        cudaMemcpyHostToDevice));

  // ---- Get (heuristic, no timing) ----
  // 注意：torch.backends.cudnn.benchmark=False 走的是 Get_v7，
  // 取 status==SUCCESS 的第一条（见 Conv_v7.cpp findAlgorithms），
  // 不是旧接口 Get(PREFER_FASTEST)。两者在本 case 上可能不同。
  std::vector<AlgoPerfRow> get_rows;
  int get_selected = -1;       // 与 torch 对齐：Get_v7 首个 SUCCESS
  int get_prefer_fastest = -1; // 旧接口，仅作对照（新版 NV cuDNN 已移除）
  {
#if defined(CUDNN_CONVOLUTION_FWD_PREFER_FASTEST)
    // Legacy API: removed from cuDNN 8+ headers on recent NVIDIA installs.
    {
      cudnnConvolutionFwdAlgo_t prefer_algo{};
      cudnnStatus_t gst = cudnnGetConvolutionForwardAlgorithm(
          handle, xDesc, wDesc, cDesc, yDesc,
          CUDNN_CONVOLUTION_FWD_PREFER_FASTEST,
          /*memoryLimitInBytes=*/0, &prefer_algo);
      if (gst == CUDNN_STATUS_SUCCESS) {
        get_prefer_fastest = (int)prefer_algo;
        std::cout
            << "\n=== cudnnGetConvolutionForwardAlgorithm(PREFER_FASTEST) "
               "[legacy, NOT used by torch] ===\n"
            << "  selected algo=" << get_prefer_fastest << " ("
            << algo_name(prefer_algo) << ")\n";
      } else {
        std::cout << "\n=== cudnnGetConvolutionForwardAlgorithm FAILED: "
                  << cudnnGetErrorString(gst) << " ===\n";
      }
    }
#else
    std::cout << "\n=== legacy Get(PREFER_FASTEST) skipped "
                 "(not in this cudnn headers) ===\n";
#endif

    int returned = 0;
    std::vector<cudnnConvolutionFwdAlgoPerf_t> perf(
        CUDNN_CONVOLUTION_FWD_ALGO_COUNT);
    cudnnStatus_t gst = cudnnGetConvolutionForwardAlgorithm_v7(
        handle, xDesc, wDesc, cDesc, yDesc, CUDNN_CONVOLUTION_FWD_ALGO_COUNT,
        &returned, perf.data());
    std::cout << "=== cudnnGetConvolutionForwardAlgorithm_v7 "
                 "[torch benchmark=False path] ===\n";
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
        row.from_get = true;
        get_rows.push_back(row);
        std::cout << "  rank" << i << " algo=" << row.algo << " (" << row.name
                  << ") status=" << row.status << " time=" << row.time_ms
                  << " ms mem=" << row.memory << std::endl;
        // torch: 按返回顺序 try_all，取第一个 SUCCESS
        if (get_selected < 0 && row.status == 0)
          get_selected = row.algo;
      }
      std::cout << "  => torch-equivalent Get_v7 pick: algo=" << get_selected
                << " ("
                << (get_selected >= 0
                        ? algo_name((cudnnConvolutionFwdAlgo_t)get_selected)
                        : "")
                << ")\n";
      if (get_prefer_fastest >= 0 && get_prefer_fastest != get_selected) {
        std::cout << "  NOTE: legacy PREFER_FASTEST=" << get_prefer_fastest
                  << " differs from Get_v7 pick=" << get_selected
                  << " (torch uses Get_v7)\n";
      }
    } else {
      std::cout << "  FAILED: " << cudnnGetErrorString(gst) << std::endl;
    }
  }

  // ---- Find (benchmark with real data) ----
  std::vector<AlgoPerfRow> find_rows;
  int find_selected = -1;
  {
    int returned = 0;
    std::vector<cudnnConvolutionFwdAlgoPerf_t> perf(
        CUDNN_CONVOLUTION_FWD_ALGO_COUNT);
    CHECK_CUDNN(cudnnFindConvolutionForwardAlgorithmEx(
        handle, xDesc, d_x, wDesc, d_w, cDesc, yDesc, d_y,
        CUDNN_CONVOLUTION_FWD_ALGO_COUNT, &returned, perf.data(), d_ws,
        max_ws));
    std::cout << "\n=== cudnnFindConvolutionForwardAlgorithmEx ===\n";
    for (int i = 0; i < returned; ++i) {
      AlgoPerfRow row;
      row.rank = i;
      row.algo = (int)perf[i].algo;
      row.name = algo_name(perf[i].algo);
      row.status = (int)perf[i].status;
      row.time_ms = perf[i].time;
      row.memory = perf[i].memory;
      row.math_type = (int)perf[i].mathType;
      row.from_find = true;
      find_rows.push_back(row);
      std::cout << "  rank" << i << " algo=" << row.algo << " (" << row.name
                << ") status=" << row.status << " time=" << row.time_ms
                << " ms mem=" << row.memory << std::endl;
      if (find_selected < 0 && row.status == 0)
        find_selected = row.algo;
    }
  }

  std::vector<int> algos;
  if (algos_str.empty() || algos_str == "all") {
    for (int a = 0; a < (int)CUDNN_CONVOLUTION_FWD_ALGO_COUNT; ++a)
      algos.push_back(a);
    std::cout << "\n=== run ALL FWD algos (0.."
              << (CUDNN_CONVOLUTION_FWD_ALGO_COUNT - 1)
              << "), unsupported will be recorded ===\n";
  } else if (algos_str == "auto") {
    // 仅 Get/Find 返回 SUCCESS 的
    std::vector<int> uniq;
    auto add_ok = [&](const std::vector<AlgoPerfRow> &rows) {
      for (const auto &r : rows) {
        if (r.status != 0)
          continue;
        if (std::find(uniq.begin(), uniq.end(), r.algo) == uniq.end())
          uniq.push_back(r.algo);
      }
    };
    add_ok(get_rows);
    add_ok(find_rows);
    std::sort(uniq.begin(), uniq.end());
    algos = uniq;
    std::cout << "\n=== auto algos from Get/Find SUCCESS ===\n  ";
    for (size_t i = 0; i < algos.size(); ++i) {
      if (i)
        std::cout << ",";
      std::cout << algos[i] << "("
                << algo_name((cudnnConvolutionFwdAlgo_t)algos[i]) << ")";
    }
    std::cout << std::endl;
  } else {
    algos = parse_algos(algos_str);
  }
  if (algos.empty()) {
    std::cerr << "no algos selected\n";
    return 1;
  }

  std::vector<RunResult> runs;
  std::cout << "\n=== per-algo forward vs golden ===\n";
  for (int a : algos) {
    auto r = run_one_algo(handle, xDesc, wDesc, cDesc, yDesc, d_x, d_w, d_y,
                          d_ws, max_ws, (cudnnConvolutionFwdAlgo_t)a, h_b, h_g,
                          y_shape);
    r.selected_by_get = (r.algo == get_selected);
    r.selected_by_find = (r.algo == find_selected);
    int get_st = -1, find_st = -1;
    for (const auto &g : get_rows)
      if (g.algo == r.algo) {
        r.get_rank = g.rank;
        get_st = g.status;
        break;
      }
    for (const auto &f : find_rows)
      if (f.algo == r.algo) {
        r.find_rank = f.rank;
        find_st = f.status;
        break;
      }
    // 若 forward 失败，把 Get/Find 的 status 一并写进 status，方便表格标“不支持”
    if (!r.ok) {
      std::ostringstream oss;
      oss << r.status;
      if (get_st > 0)
        oss << "; Get.status=" << get_st;
      if (find_st > 0)
        oss << "; Find.status=" << find_st;
      if (get_st == 3000 || find_st == 3000 ||
          r.status.find("NOT_SUPPORTED") != std::string::npos ||
          r.status.find("not supported") != std::string::npos) {
        // 统一前缀，Excel 可直接显示
        r.status = std::string("不支持/报错: ") + oss.str();
      } else {
        r.status = std::string("报错: ") + oss.str();
      }
    }
    runs.push_back(r);

    if (r.ok) {
      std::cout << "algo" << r.algo << " " << r.name << " ok=1"
                << " get_sel=" << r.selected_by_get
                << " find_sel=" << r.selected_by_find
                << " get_rank=" << r.get_rank << " find_rank=" << r.find_rank
                << "\n  vs_golden: exact=" << r.vs_golden.exact
                << " non_eq=" << r.vs_golden.non_equal
                << " mae=" << r.vs_golden.mae
                << " max_abs=" << r.vs_golden.max_abs
                << " mean_rel=" << r.vs_golden.mean_rel
                << " max_rel=" << r.vs_golden.max_rel
                << " rel_l2=" << r.vs_golden.rel_l2
                << " cosine=" << r.vs_golden.cosine_sim
                << " sim=" << r.vs_golden.similarity << std::endl;
      std::string dump = "out_algo" + std::to_string(r.algo) + ".bf16.bin";
      std::ofstream ofs(dump, std::ios::binary);
      ofs.write(reinterpret_cast<const char *>(r.out_bf16.data()),
                (std::streamsize)(r.out_bf16.size() * sizeof(uint16_t)));
    } else {
      std::cout << "algo" << r.algo << " " << r.name << " ok=0 status="
                << r.status << std::endl;
    }
  }

  // ---- 选择对比基线 ----
  int baseline_algo = -1;
  const uint16_t *baseline_out = h_g;
  if (baseline_mode == "self") {
    auto find_ok = [&](int algo) -> const RunResult * {
      for (const auto &r : runs)
        if (r.ok && r.algo == algo)
          return &r;
      return nullptr;
    };
    if (baseline_algo_str != "auto") {
      baseline_algo = std::atoi(baseline_algo_str.c_str());
    } else if (find_ok(get_selected)) {
      baseline_algo = get_selected;
    } else if (find_ok(find_selected)) {
      baseline_algo = find_selected;
    } else {
      for (const auto &r : runs)
        if (r.ok) {
          baseline_algo = r.algo;
          break;
        }
    }
    const RunResult *bref = find_ok(baseline_algo);
    if (!bref) {
      std::cerr << "baseline=self but ref algo " << baseline_algo
                << " not available\n";
      return 1;
    }
    baseline_out = bref->out_bf16.data();
    std::cout << "\n=== baseline=self ref_algo=" << baseline_algo << " ("
              << algo_name((cudnnConvolutionFwdAlgo_t)baseline_algo)
              << ") ===\n";
    for (auto &r : runs) {
      if (!r.ok)
        continue;
      r.vs_golden =
          diff_bf16(r.out_bf16.data(), baseline_out, r.out_bf16.size());
      std::cout << "algo" << r.algo << " vs ref: exact=" << r.vs_golden.exact
                << " non_eq=" << r.vs_golden.non_equal
                << " max_abs=" << r.vs_golden.max_abs << std::endl;
    }
  } else {
    baseline_mode = "file";
    std::cout << "\n=== baseline=file (golden/out) ===\n";
  }

  bool all_supported_exact = true;
  int supported_n = 0;
  for (const auto &r : runs) {
    if (!r.ok)
      continue;
    ++supported_n;
    if (!r.vs_golden.exact)
      all_supported_exact = false;
  }
  std::cout << "\n=== verdict: supported=" << supported_n
            << " all_exact_to_baseline=" << all_supported_exact << " ===\n";

  std::cout << "\n=== pairwise (supported only) ===\n";
  for (size_t i = 0; i < runs.size(); ++i) {
    if (!runs[i].ok)
      continue;
    for (size_t j = i + 1; j < runs.size(); ++j) {
      if (!runs[j].ok)
        continue;
      auto d = diff_bf16(runs[i].out_bf16.data(), runs[j].out_bf16.data(),
                         runs[i].out_bf16.size());
      std::cout << "algo" << runs[i].algo << " vs algo" << runs[j].algo
                << ": exact=" << d.exact << " non_eq=" << d.non_equal
                << " max_abs=" << d.max_abs << " max_rel=" << d.max_rel
                << " rel_l2=" << d.rel_l2 << std::endl;
    }
  }

  if (!save_golden_dir.empty()) {
    if (baseline_mode != "self" || baseline_algo < 0) {
      std::cerr << "--save-golden requires --baseline self and a valid ref\n";
      return 1;
    }
    const RunResult *bref = nullptr;
    for (const auto &r : runs)
      if (r.ok && r.algo == baseline_algo)
        bref = &r;
    if (!bref) {
      std::cerr << "cannot save golden: ref algo missing\n";
      return 1;
    }
    // mkdir -p via shell-ish: create by writing files; parent must exist or use
    // a simple recursive approach
    std::string cmd = "mkdir -p \"" + save_golden_dir + "\"";
    if (std::system(cmd.c_str()) != 0) {
      std::cerr << "mkdir failed: " << save_golden_dir << std::endl;
      return 1;
    }
    if (!write_bin_copy(golden_dir + "/padded.bf16.bin",
                        save_golden_dir + "/padded.bf16.bin") ||
        !write_bin_copy(golden_dir + "/weight.bf16.bin",
                        save_golden_dir + "/weight.bf16.bin") ||
        !write_bin_copy(golden_dir + "/bias.bf16.bin",
                        save_golden_dir + "/bias.bf16.bin")) {
      return 1;
    }
    {
      std::ofstream ofs(save_golden_dir + "/out_golden.bf16.bin",
                        std::ios::binary);
      ofs.write(reinterpret_cast<const char *>(bref->out_bf16.data()),
                (std::streamsize)(bref->out_bf16.size() * sizeof(uint16_t)));
    }
    write_bin_copy(golden_dir + "/padded.f32.bin",
                   save_golden_dir + "/padded.f32.bin", false);
    write_bin_copy(golden_dir + "/weight.f32.bin",
                   save_golden_dir + "/weight.f32.bin", false);
    write_bin_copy(golden_dir + "/bias.f32.bin",
                   save_golden_dir + "/bias.f32.bin", false);
    {
      std::ofstream meta(save_golden_dir + "/meta_note.txt");
      meta << "source_device=" << prop.name << "\n"
           << "baseline_algo=" << baseline_algo << " "
           << algo_name((cudnnConvolutionFwdAlgo_t)baseline_algo) << "\n"
           << "inputs_from=" << golden_dir << "\n"
           << "note=out_golden is NV/local ref algo output\n";
    }
    std::cout << "saved golden pack -> " << save_golden_dir
              << " (ref algo=" << baseline_algo << ")\n";
  }

  write_summary_json(out_json, runs, get_rows, find_rows, get_selected,
                     get_prefer_fastest, find_selected, golden_dir, prop.name,
                     baseline_mode, baseline_algo, save_golden_dir,
                     all_supported_exact);
  std::cout << "\nwrote " << out_json << std::endl;

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
