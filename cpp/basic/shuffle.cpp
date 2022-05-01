#include <stdio.h>
#include <iostream>
#include <cmath>

int main(int argc, char* argv[]){
    int warpSize = 32;
    int width = 8;
    int c = ((warpSize-width) << 8) | 0x1f;

    /*
       0000000010000; 16
    <<8
       1000000000000; 4096
    |  0000000001111; 31
    =  1000000001111; 4127
    */

    /*
       0000000011000; 24
    <<8
       1100000000000; 4096+2048=6144
    |  0000000001111; 
    =  1100000001111; 6144+31 = 6175
    */
    int ref = std::pow(2, 12);
    printf("c is: %d \n", c);
    printf("ref is: %d \n", ref);
}