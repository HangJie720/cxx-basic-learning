/*
两个数组的交集
返回两个数组的交集（含重复元素）。
*/

#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>

using namespace std;

class Solution {
public:
    vector<int> intersect(vector<int>& a, vector<int>& b) {
        unordered_map<int, int> cnt;
        for (int x : a) ++cnt[x];
        vector<int> ans;
        for (int x : b) if (cnt[x]-- > 0) ans.push_back(x);
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> a = {1, 2, 2, 1}, b = {2, 2};
    auto r = s.intersect(a, b);
    for (int x : r) cout << x << " ";  // 2 2
    cout << endl;
    return 0;
}
