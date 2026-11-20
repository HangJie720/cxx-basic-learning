/*
x 的平方根
返回整数 x 的算术平方根的整数部分。
*/

#include <iostream>

using namespace std;

class Solution {
public:
    int mySqrt(int x) {
        if (x <= 1) return x;
        int l = 1, r = x;
        while (l <= r) {
            long m = (long)l + r >> 1;
            if (m * m <= x) l = m + 1;
            else r = m - 1;
        }
        return r;
    }
};

int main() {
    Solution s;
    cout << s.mySqrt(8) << endl;   // 2
    cout << s.mySqrt(4) << endl;   // 2
    return 0;
}
