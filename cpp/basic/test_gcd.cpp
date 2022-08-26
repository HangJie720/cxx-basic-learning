#include <iostream>

unsigned gcd ( unsigned a , unsigned b) {
    if(b == 0) return a ;
    while (b != 0) {
        unsigned t = a % b;
        a = b;
        b = t;
    }
    return a ;
}

int main(){
    int a = 4;
    int b = 2;
    int c = 0;
    c = gcd(a, b);
    printf("c is: %d \n", c);
    return 0;
}