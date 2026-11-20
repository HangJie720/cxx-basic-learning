/*
合并区间
合并所有重叠的区间。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    vector<vector<int>> merge(vector<vector<int>>& intervals) {
        sort(intervals.begin(), intervals.end());
        vector<vector<int>> ans;
        for (auto& v : intervals) {
            if (ans.empty() || ans.back()[1] < v[0]) ans.push_back(v);
            else ans.back()[1] = max(ans.back()[1], v[1]);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<vector<int>> in = {{1, 3}, {2, 6}, {8, 10}, {15, 18}};
    auto r = s.merge(in);
    for (auto& v : r) cout << "[" << v[0] << "," << v[1] << "] ";
    cout << endl;  // [1,6] [8,10] [15,18]
    return 0;
}
