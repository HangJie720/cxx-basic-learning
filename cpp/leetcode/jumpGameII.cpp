/*
跳跃游戏 II
返回跳到最后一个下标的最少跳跃次数。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int jump(vector<int>& nums) {
        int ans = 0, end = 0, reach = 0;
        for (int i = 0; i < (int)nums.size() - 1; ++i) {
            reach = max(reach, i + nums[i]);
            if (i == end) { ++ans; end = reach; }
        }
        return ans;
    }
};

int main() {
    Solution s;
    vector<int> nums = {2, 3, 1, 1, 4};
    cout << s.jump(nums) << endl;  // 2
    return 0;
}
