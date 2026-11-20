/*
分割等和子集
判断非空正整数数组能否分成两个元素和相等的子集。
*/

#include <iostream>
#include <vector>
#include <numeric>

using namespace std;

class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = accumulate(nums.begin(), nums.end(), 0);
        if (sum % 2) return false;
        int target = sum / 2;
        vector<bool> dp(target + 1);
        dp[0] = true;
        for (int x : nums)
            for (int j = target; j >= x; --j)
                dp[j] = dp[j] || dp[j - x];
        return dp[target];
    }
};

int main() {
    Solution s;
    vector<int> n = {1, 5, 11, 5};
    cout << s.canPartition(n) << endl;  // 1
    return 0;
}
