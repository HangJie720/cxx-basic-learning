/*
下一个排列
将整数数组重排为字典序的下一个排列。若已是最大，则升序排列。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        int n = nums.size(), i = n - 2;
        while (i >= 0 && nums[i] >= nums[i + 1]) --i;
        if (i >= 0) {
            int j = n - 1;
            while (nums[j] <= nums[i]) --j;
            swap(nums[i], nums[j]);
        }
        reverse(nums.begin() + i + 1, nums.end());
    }
};

int main() {
    Solution s;
    vector<int> nums = {1, 2, 3};
    s.nextPermutation(nums);
    for (int x : nums) cout << x << " ";  // 1 3 2
    cout << endl;
    return 0;
}
