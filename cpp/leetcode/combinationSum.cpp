/*
组合总和
无重复候选数组，找出所有使数字和为 target 的组合，数字可重复使用。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
        vector<vector<int>> ans;
        vector<int> cur;
        dfs(candidates, 0, target, cur, ans);
        return ans;
    }
    void dfs(vector<int>& c, int i, int t, vector<int>& cur, vector<vector<int>>& ans) {
        if (t == 0) { ans.push_back(cur); return; }
        if (t < 0 || i == (int)c.size()) return;
        cur.push_back(c[i]);
        dfs(c, i, t - c[i], cur, ans);
        cur.pop_back();
        dfs(c, i + 1, t, cur, ans);
    }
};

int main() {
    Solution s;
    vector<int> c = {2, 3, 6, 7};
    auto r = s.combinationSum(c, 7);
    for (auto& v : r) {
        for (int x : v) cout << x << " ";
        cout << "| ";
    }
    cout << endl;  // 2 2 3 | 7
    return 0;
}
