/*
滑动窗口最大值
返回数组每个大小为 k 的滑动窗口的最大值。
*/

#include <iostream>
#include <vector>
#include <deque>

using namespace std;

class Solution {
public:
    vector<int> maxSlidingWindow(vector<int>& nums, int k) {
        vector<int> ans;
        deque<int> dq;
        for (int i = 0; i < (int)nums.size(); ++i) {
            while (!dq.empty() && nums[dq.back()] <= nums[i]) dq.pop_back();
            dq.push_back(i);
            if (dq.front() <= i - k) dq.pop_front();
            if (i >= k - 1) ans.push_back(nums[dq.front()]);
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 3, -1, -3, 5, 3, 6, 7};
    auto r = s.maxSlidingWindow(nums, 3);
    for (int x : r) cout << x << " ";  // 3 3 5 5 6 7
    cout << endl;
    return 0;
}
