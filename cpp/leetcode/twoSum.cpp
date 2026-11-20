/*
两数之和
给定一个整数数组 nums 和一个目标值 target，返回和为 target 的两个元素下标。
*/

#include <iostream>
#include <vector>
#include <unordered_map>

using namespace std;

class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        unordered_map<int, int> mp;
        for (int i = 0; i < (int)nums.size(); ++i) {
            int need = target - nums[i];
            if (mp.count(need)) return {mp[need], i};
            mp[nums[i]] = i;
        }
        return {};
    }
};

int main() {
    Solution s;
    vector<int> nums = {2, 7, 11, 15};
    auto r = s.twoSum(nums, 9);
    for (int x : r) cout << x << " ";
    cout << endl;
    return 0;
}
