/*
数组中的逆序对
返回数组中的逆序对总数。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    int reversePairs(vector<int>& nums) {
        if (nums.empty()) return 0;
        return mergeSort(nums, 0, nums.size() - 1);
    }
    int mergeSort(vector<int>& nums, int l, int r) {
        if (l >= r) return 0;
        int m = (l + r) / 2;
        int cnt = mergeSort(nums, l, m) + mergeSort(nums, m + 1, r);
        vector<int> tmp(nums.begin() + l, nums.begin() + r + 1);
        int i = l, j = m + 1, k = l;
        while (i <= m && j <= r) {
            if (nums[i] <= nums[j]) tmp[k++] = nums[i++];
            else { tmp[k++] = nums[j++]; cnt += m - i + 1; }
        }
        while (i <= m) tmp[k++] = nums[i++];
        while (j <= r) tmp[k++] = nums[j++];
        for (int x = l; x <= r; ++x) nums[x] = tmp[x];
        return cnt;
    }
};

int main() {
    Solution s;
    vector<int> n = {7, 5, 6, 4};
    cout << s.reversePairs(n) << endl;  // 5
    return 0;
}
