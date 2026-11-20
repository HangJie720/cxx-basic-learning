/*
盛最多水的容器
返回数组中两条线与 x 轴围成容器的最大水量。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int maxArea(vector<int>& height) {
        int l = 0, r = height.size() - 1, ans = 0;
        while (l < r) {
            int h = min(height[l], height[r]);
            ans = max(ans, h * (r - l));
            if (height[l] < height[r]) ++l; else --r;
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> h = {1, 8, 6, 2, 5, 4, 8, 3, 7};
    cout << s.maxArea(h) << endl;  // 49
    return 0;
}
