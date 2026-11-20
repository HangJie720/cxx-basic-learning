/*
接雨水
给定柱高数组，返回能接住的雨水总量。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int trap(vector<int>& height) {
        int l = 0, r = height.size() - 1, lmax = 0, rmax = 0, ans = 0;
        while (l < r) {
            if (height[l] < height[r]) {
                if (height[l] >= lmax) lmax = height[l];
                else ans += lmax - height[l];
                ++l;
            } else {
                if (height[r] >= rmax) rmax = height[r];
                else ans += rmax - height[r];
                --r;
            }
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> h = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};
    cout << s.trap(h) << endl;  // 6
    return 0;
}
