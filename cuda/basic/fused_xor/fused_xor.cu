
extern "C" __global__
void fused___xor__(bool* tx, long long* aten_xor) {
{
if ((long long)(threadIdx.x) + 512ll * (long long)(blockIdx.x)<2ll ? 1 : 0) {
    long long v = (long long)(tx[(long long)(threadIdx.x) + 512ll * (long long)(blockIdx.x)]);
    aten_xor[(long long)(threadIdx.x) + 512ll * (long long)(blockIdx.x)] = v ^ -1ll;
  }}
}
