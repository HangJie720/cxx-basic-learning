/*
爬楼梯
n 阶楼梯，每次可爬 1 或 2 阶，爬到顶有多少种方法。
*/

#include <iostream>

using namespace std;

class Solution {
public:
    int climbStairs(int n) {
        if (n <= 2) return n;
        int a = 1, b = 2;
        for (int i = 3; i <= n; ++i) {
            int c = a + b;
            a = b;
            b = c;
        }
        return b;
    }
};

int main() {
    Solution s;
    cout << s.climbStairs(5) << endl;  // 8
    return 0;
}
