
#include <string>
#include <sstream>

int main() {
    // std::string fnames[] = {"foo.txt", "bar.txt", "test", "a0.txt", "AAA.txt"};
    // std::regex txt_regex("[a-z]+\\.txt");
    // for (const auto &fname: fnames)
    //     std::cout << fname << ": " << std::regex_match(fname, txt_regex) << std::endl;

    std::string rflags[] = {"--source-in-ptx", "-Xfatbin", "-compress-all", "--expt-extended-lambda", "--expt-relaxed-constexpr"};
    std::string strT = "--cuda-gpu-arch=ivcore10 --expt-extended-lambda --source-in-ptx --source-in-ptx -Xfatbin -compress-all --expt-extended-lambda --expt-relaxed-constexpr -gencode=arch=compute_70,code=sm_70 -O3 -DNDEBUG --diag_suppress=xxx --diag_suppress=xaxx -gencode arch=compute_61,code=sm_61";

    std::istringstream str(strT);	
	std::string out;
    int pos = 0;
    for (const auto &rflag: rflags){
        while ((pos = strT.find(rflag)) != -1) {
            strT.erase(pos, rflag.size());
        }
    }
	while (str >> out) {
        if ((out.find("gencode") != -1) or (out.find("arch=compute") != -1) or (out.find("diag_suppress") != -1)){
            while ((pos = strT.find(out)) != -1) {
		        strT.erase(pos, out.size());
            }
        }
	}
    // std::cout << strT << std::endl;
}
