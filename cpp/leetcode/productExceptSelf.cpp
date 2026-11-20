/*
除自身以外数组的乘积
返回数组 ans，ans[i] 等于 nums 中除 nums[i] 外其余元素乘积。O(n)，不用除法。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int n = nums.size();
        vector<int> ans(n, 1);
        int left = 1;
        for (int i = 0; i < n; ++i) { ans[i] = left; left *= nums[i]; }
        int right = 1;
        for (int i = n - 1; i >= 0; --i) { ans[i] *= right; right *= nums[i]; }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 2, 3, 4};
    auto r = s.productExceptSelf(nums);
    for (int x : r) cout << x << " ";  // 24 12 8 6
    cout << endl;
    return 0;
}
