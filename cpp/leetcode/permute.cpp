/*
全排列
返回不含重复数字数组的所有全排列。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<vector<int>> permute(vector<int>& nums) {
        vector<vector<int>> ans;
        dfs(nums, 0, ans);
        return ans;
    }
    void dfs(vector<int>& nums, int start, vector<vector<int>>& ans) {
        if (start == (int)nums.size()) { ans.push_back(nums); return; }
        for (int i = start; i < (int)nums.size(); ++i) {
            swap(nums[start], nums[i]);
            dfs(nums, start + 1, ans);
            swap(nums[start], nums[i]);
        }
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 2, 3};
    auto r = s.permute(nums);
    for (auto& v : r) {
        for (int x : v) cout << x << " ";
        cout << "| ";
    }
    cout << endl;
    return 0;
}
