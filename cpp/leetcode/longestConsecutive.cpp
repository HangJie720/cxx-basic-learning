/*
最长连续序列
返回无序数组中最长连续序列的长度，要求 O(n)。
*/

#include <iostream>
#include <vector>
#include <unordered_set>

using namespace std;

class Solution {
public:
    int longestConsecutive(vector<int>& nums) {
        unordered_set<int> st(nums.begin(), nums.end());
        int ans = 0;
        for (int x : nums) {
            if (!st.count(x - 1)) {
                int cur = x, len = 1;
                while (st.count(cur + 1)) { ++cur; ++len; }
                ans = max(ans, len);
            }
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> n = {100, 4, 200, 1, 3, 2};
    cout << s.longestConsecutive(n) << endl;  // 4
    return 0;
}
