/*
最大子数组和
返回数组中连续子数组的最大和。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int cur = nums[0], ans = nums[0];
        for (int i = 1; i < (int)nums.size(); ++i) {
            cur = max(nums[i], cur + nums[i]);
            ans = max(ans, cur);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    cout << s.maxSubArray(nums) << endl;  // 6
    return 0;
}
