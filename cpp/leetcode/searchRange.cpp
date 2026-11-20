/*
在排序数组中查找元素的第一个和最后一个位置
O(log n) 返回目标值在升序数组中的起止下标，没有返回 [-1,-1]。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        int l = lower(nums, target), r = upper(nums, target) - 1;
        if (l <= r && l < (int)nums.size() && nums[l] == target) return {l, r};
        return {-1, -1};
    }
    int lower(vector<int>& n, int t) {
        int l = 0, r = n.size();
        while (l < r) { int m = (l + r) / 2; if (n[m] < t) l = m + 1; else r = m; }
        return l;
    }
    int upper(vector<int>& n, int t) {
        int l = 0, r = n.size();
        while (l < r) { int m = (l + r) / 2; if (n[m] <= t) l = m + 1; else r = m; }
        return l;
    }
};

int main() {
    Solution s;
    vector<int> n = {5, 7, 7, 8, 8, 10};
    auto r = s.searchRange(n, 8);
    cout << r[0] << " " << r[1] << endl;  // 3 4
    return 0;
}
