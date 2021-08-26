#include <stdio.h>
#include <iostream>
#include <algorithm>

int main(int argc, char* argv[]){
    if (sizeof(long)==sizeof(long long)){
        printf("equal \n");
	printf("sizeof of long type is: %u \n", sizeof(long));
    }else{
        printf("not equal \n");
    }
    printf("sizeof of long type is: %u \n", sizeof(double));
    return 0;
}
