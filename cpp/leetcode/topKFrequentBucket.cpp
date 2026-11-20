/*
实现前 K 个高频元素（桶排序版）
见 topKFrequent.cpp 的堆版本，此处用桶排序。
*/

#include <iostream>
#include <vector>
#include <unordered_map>

using namespace std;

class Solution {
public:
    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int, int> cnt;
        int maxc = 0;
        for (int x : nums) maxc = max(maxc, ++cnt[x]);
        vector<vector<int>> bucket(maxc + 1);
        for (auto& p : cnt) bucket[p.second].push_back(p.first);
        vector<int> ans;
        for (int f = maxc; f >= 0 && (int)ans.size() < k; --f)
            for (int x : bucket[f]) { ans.push_back(x); if ((int)ans.size() == k) break; }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> n = {1, 1, 1, 2, 2, 3};
    auto r = s.topKFrequent(n, 2);
    for (int x : r) cout << x << " ";  // 1 2
    cout << endl;
    return 0;
}
