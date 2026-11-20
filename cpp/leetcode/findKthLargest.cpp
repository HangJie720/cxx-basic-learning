/*
数组中的第 K 个最大元素
返回无序数组中第 k 个最大元素。
*/

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        int l = 0, r = nums.size() - 1, target = nums.size() - k;
        while (true) {
            int p = partition(nums, l, r);
            if (p == target) return nums[p];
            else if (p < target) l = p + 1;
            else r = p - 1;
        }
    }
    int partition(vector<int>& nums, int l, int r) {
        int pivot = nums[r], i = l;
        for (int j = l; j < r; ++j) {
            if (nums[j] <= pivot) swap(nums[i++], nums[j]);
        }
        swap(nums[i], nums[r]);
        return i;
    }
};

int main() {
    Solution s;
    vector<int> nums = {3, 2, 1, 5, 6, 4};
    cout << s.findKthLargest(nums, 2) << endl;  // 5
    return 0;
}
