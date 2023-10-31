/*
斐波那契数列
*/

#include <iostream>
#include <algorithm>  
#include <string>
#include <vector>

using namespace std;

class Solution {
public:
    int Fibonacci(int n) {
        vector<int> dp(n + 1);
        dp[1] = 1;
        dp[2] = 1;
        for(int i = 3; i <= n; i++){
            dp[i] = dp[i-1] + dp[i-2];
        }
        return dp[n];
    }
};
class Solution1 {
public:
    int Fibonacci(int n) {
        int a=1 , b=1 , c=1;
        if (n==1||n==2) return 1;
        for(int i = 3; i<=n ; i++)
        {
            c=a+b;
            a=b;
            b=c;
        }
        return c;
    }
};
  
int fibonacci(int n) {  
    if (n <= 1) {  
        return n;  
    } else {  
        return fibonacci(n-1) + fibonacci(n-2);  
    }  
}  
  
int main() {  
    int n;
    Solution s;
    Solution1 s1;
    std::cout << "请输入一个正整数n：";  
    std::cin >> n;  
    std::cout << "方案1：斐波拉契数列的第" << n << "项为：" << fibonacci(n) << std::endl;  
    std::cout << "方案2：斐波拉契数列的第" << n << "项为：" << s.Fibonacci(n) << std::endl;  
    std::cout << "方案3：斐波拉契数列的第" << n << "项为：" << s1.Fibonacci(n) << std::endl;  
    return 0;  
}