#include <iostream>
#include <string.h>
#include <typeinfo>
#include <stdio.h>

using namespace std;
int main(){
    char str[] = "random_from_to_kernel_cuda";
    char *lc = strchr(str, 'cudaa');
    printf("strchr： %s\n", lc);
    char *rc = strrchr(str, 'cuda1');
    printf("strrchr： %s\n", rc);
    return 0;
}