/*
乘积最大子数组
返回数组中连续子数组的最大乘积。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxProduct(vector<int>& nums) {
        int ans = nums[0], mx = nums[0], mn = nums[0];
        for (int i = 1; i < (int)nums.size(); ++i) {
            int a = mx * nums[i], b = mn * nums[i];
            mx = max(nums[i], max(a, b));
            mn = min(nums[i], min(a, b));
            ans = max(ans, mx);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> n = {2, 3, -2, 4};
    cout << s.maxProduct(n) << endl;  // 6
    return 0;
}
