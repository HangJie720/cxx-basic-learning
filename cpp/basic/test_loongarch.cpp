#include <stdio.h>
#include <iostream>
#include <algorithm>

using namespace std;
int main(){
#if defined(__loongarch64__)
  std::cout << "aaa"<< std::endl;
#elif defined(__loongarch__)
  std::cout << "bbb"<< std::endl;
#else
  std::cout << "ccc" << std::endl;
#endif
}
