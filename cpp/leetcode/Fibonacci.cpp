/*
斐波那契数列
*/
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
class Solution {
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