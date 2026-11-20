/*
缺失的第一个正数
返回未排序数组中缺失的最小正整数，要求 O(n) 时间 O(1) 空间。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int firstMissingPositive(vector<int>& nums) {
        int n = nums.size();
        for (int i = 0; i < n; ++i)
            while (nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] != nums[i])
                swap(nums[i], nums[nums[i] - 1]);
        for (int i = 0; i < n; ++i) if (nums[i] != i + 1) return i + 1;
        return n + 1;
    }
};

int main() {
    Solution s;
    vector<int> n = {3, 4, -1, 1};
    cout << s.firstMissingPositive(n) << endl;  // 2
    return 0;
}
