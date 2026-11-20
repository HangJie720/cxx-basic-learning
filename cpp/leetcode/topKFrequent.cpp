/*
前 K 个高频元素
返回数组中出现频率前 k 高的元素。
*/

#include <iostream>
#include <vector>
#include <unordered_map>
#include <queue>

using namespace std;

class Solution {
public:
    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int, int> cnt;
        for (int x : nums) ++cnt[x];
        auto cmp = [](pair<int, int>& a, pair<int, int>& b) { return a.second > b.second; };
        priority_queue<pair<int, int>, vector<pair<int, int>>, decltype(cmp)> pq(cmp);
        for (auto& p : cnt) {
            pq.push(p);
            if ((int)pq.size() > k) pq.pop();
        }
        vector<int> ans;
        while (!pq.empty()) { ans.push_back(pq.top().first); pq.pop(); }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 1, 1, 2, 2, 3};
    auto r = s.topKFrequent(nums, 2);
    for (int x : r) cout << x << " ";  // 1 2
    cout << endl;
    return 0;
}
