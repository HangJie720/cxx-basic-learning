/*
天际线问题
返回建筑物轮廓的关键点。
*/

#include <iostream>
#include <vector>
#include <set>
#include <algorithm>

using namespace std;

class Solution {
public:
    vector<vector<int>> getSkyline(vector<vector<int>>& buildings) {
        vector<pair<int, int>> pts;
        for (auto& b : buildings) {
            pts.push_back({b[0], -b[2]});
            pts.push_back({b[1], b[2]});
        }
        sort(pts.begin(), pts.end());
        multiset<int> hs{0};
        vector<vector<int>> ans;
        int prev = 0;
        for (auto& p : pts) {
            if (p.second < 0) hs.insert(-p.second);
            else hs.erase(hs.find(p.second));
            int cur = *hs.rbegin();
            if (cur != prev) { ans.push_back({p.first, cur}); prev = cur; }
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<vector<int>> b = {{2, 9, 10}, {3, 7, 15}, {5, 12, 12}, {15, 20, 10}, {19, 24, 8}};
    auto r = s.getSkyline(b);
    for (auto& v : r) cout << "[" << v[0] << "," << v[1] << "] ";
    cout << endl;
    return 0;
}
