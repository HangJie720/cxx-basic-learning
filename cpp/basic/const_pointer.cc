#include <iostream>
#include <stdio.h>
#include <iostream>
#include <stdio.h>

int main(int arg, char *argv[])
{
    const int a = 1;
    const int &b = a;
    const int *c = &a;
    const int *const d = c;
   
    printf("a is: %d \n", a);
    printf("b is: %d \n", b);
    printf("c is: %d \n", *c);
    printf("d is: %d \n", *d);

    const int z = 2;
    const int *x = &z;

    c = x;

    printf("c is: %d \n", *c);
    //d = x;

    //printf("d is: %d \n", *d);
}
