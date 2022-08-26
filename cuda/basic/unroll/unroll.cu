#include <stdio.h>
#include <algorithm>
#include <stdlib.h>
#include <iostream>
using namespace std;

int foo(int c)
{   
    size_t w = 0;
    size_t i = sizeof(size_t);

    #pragma unroll
    while(i--)
    {
        w = (w << 8) | c;
    }

    return w;
}
int main(int argc, char *argv[]){
    int a;
    a = foo(3);
    std::cout<< "the value of a is: " << a << std::endl;
    return 0;
}
