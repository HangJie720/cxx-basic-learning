/*
打家劫舍
不能偷相邻两间房，返回能偷到的最大金额。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int rob(vector<int>& nums) {
        int prev = 0, cur = 0;
        for (int x : nums) {
            int t = max(cur, prev + x);
            prev = cur;
            cur = t;
        }
        return cur;
    }
};

int main() {
    Solution s;
    vector<int> n = {2, 7, 9, 3, 1};
    cout << s.rob(n) << endl;  // 12
    return 0;
}
