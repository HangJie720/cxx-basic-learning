#include <iostream>
#include <string.h>
#include <typeinfo>
#include <stdio.h>

using namespace std;
int main(){
    char str[] = "random_from_to_kernel_cuda";
    char *lc = strstr(str, "cuda");
    printf("strchr： %s\n", lc);
    return 0;
}