#include <iostream>
#include <string.h>
#include <sstream>
#include <iterator>
#include <vector>
#include <algorithm>
#include <stdio.h>

int main(void)
{
	// char *pathvar;
	char *pathvar = getenv("CMAKE_CUDA_ARCHITECTURES");
    if(pathvar != nullptr){
        std::string my_string(pathvar);
	    printf("pathvar=%s \n",my_string.c_str());
        std::string splited_string;
        std::stringstream ss(my_string);
        while (std::getline(ss, splited_string, ' ')) {
            std::cout<< "splited_string is: " << splited_string << std::endl;
        }
    }else{
        printf("pathvar is null \n");
    }

    // char *pathvar = getenv("CMAKE_CUDA_ARCHITECTURES");
    // if(pathvar != nullptr){
    //     char *p = strtok(pathvar, " ");
    //     if(p)
    //     {
    //         printf("%s\n", p);
    //     }
    //     p = strtok(NULL, " ");

    //     if(p)
    //        printf("%s\n", p);
    // }else{
    //     printf("pathvar is null \n");
    // }

	return 0;
}