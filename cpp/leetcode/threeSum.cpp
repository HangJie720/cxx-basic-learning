/*
三数之和
返回数组中所有和为 0 的不重复三元组。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        vector<vector<int>> ans;
        sort(nums.begin(), nums.end());
        int n = nums.size();
        for (int i = 0; i < n - 2; ++i) {
            if (i && nums[i] == nums[i - 1]) continue;
            int l = i + 1, r = n - 1, target = -nums[i];
            while (l < r) {
                int sum = nums[l] + nums[r];
                if (sum == target) {
                    ans.push_back({nums[i], nums[l], nums[r]});
                    while (l < r && nums[l] == nums[l + 1]) ++l;
                    while (l < r && nums[r] == nums[r - 1]) --r;
                    ++l; --r;
                } else if (sum < target) ++l;
                else --r;
            }
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {-1, 0, 1, 2, -1, -4};
    auto r = s.threeSum(nums);
    for (auto& v : r) {
        for (int x : v) cout << x << " ";
        cout << "| ";
    }
    cout << endl;  // -1 -1 2 | -1 0 1 |
    return 0;
}
