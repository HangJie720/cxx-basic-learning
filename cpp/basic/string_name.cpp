#include <iostream>
#include <string>
#include <typeinfo>

using namespace std;
int main(){
  string s;
  std::cout << typeid(s).name() << std::endl;
}

