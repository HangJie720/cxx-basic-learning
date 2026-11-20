/*
子集
返回不含重复元素整数数组的所有子集。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<vector<int>> subsets(vector<int>& nums) {
        vector<vector<int>> ans;
        vector<int> cur;
        dfs(nums, 0, cur, ans);
        return ans;
    }
    void dfs(vector<int>& nums, int i, vector<int>& cur, vector<vector<int>>& ans) {
        ans.push_back(cur);
        for (int j = i; j < (int)nums.size(); ++j) {
            cur.push_back(nums[j]);
            dfs(nums, j + 1, cur, ans);
            cur.pop_back();
        }
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 2, 3};
    auto r = s.subsets(nums);
    for (auto& v : r) {
        cout << "[";
        for (int x : v) cout << x << " ";
        cout << "] ";
    }
    cout << endl;
    return 0;
}
