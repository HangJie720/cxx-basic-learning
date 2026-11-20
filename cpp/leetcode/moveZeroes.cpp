/*
移动零
将数组中所有 0 移到末尾，保持非零元素相对顺序，原地操作。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int j = 0;
        for (int i = 0; i < (int)nums.size(); ++i) {
            if (nums[i] != 0) nums[j++] = nums[i];
        }
        while (j < (int)nums.size()) nums[j++] = 0;
    }
};

int main() {
    Solution s;
    vector<int> nums = {0, 1, 0, 3, 12};
    s.moveZeroes(nums);
    for (int x : nums) cout << x << " ";  // 1 3 12 0 0
    cout << endl;
    return 0;
}
