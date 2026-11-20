/*
跳跃游戏
判断能否从下标 0 跳到数组最后一个下标。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    bool canJump(vector<int>& nums) {
        int reach = 0;
        for (int i = 0; i <= reach && i < (int)nums.size(); ++i) {
            reach = max(reach, i + nums[i]);
        }
        return reach >= (int)nums.size() - 1;
    }
};

int main() {
    Solution s;
    vector<int> a = {2, 3, 1, 1, 4};
    vector<int> b = {3, 2, 1, 0, 4};
    cout << s.canJump(a) << endl;  // 1
    cout << s.canJump(b) << endl;  // 0
    return 0;
}
