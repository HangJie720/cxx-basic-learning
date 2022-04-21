#include <iostream>
#include <vector>
#include <stdio.h>

int main(int argc, char **argv){
    std::vector<int> a;
    for (int i =0; i< 10; i++){
        a.push_back(i);
    }
    for (int j = 0; j < 10; ++j){
        printf("a[%d] is: %d \n", j, a[j]);
    }
    return 0;
}