/*
合并两个有序数组（双指针原地版）
见 mergeSortedArray.cpp 的从后往前填充版本，此处为正向双指针+额外空间。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        vector<int> tmp(nums1.begin(), nums1.begin() + m);
        int i = 0, j = 0, k = 0;
        while (i < m && j < n) nums1[k++] = tmp[i] <= nums2[j] ? tmp[i++] : nums2[j++];
        while (i < m) nums1[k++] = tmp[i++];
        while (j < n) nums1[k++] = nums2[j++];
    }
};

int main() {
    Solution s;
    vector<int> a = {1, 2, 3, 0, 0, 0};
    vector<int> b = {2, 5, 6};
    s.merge(a, 3, b, 3);
    for (int x : a) cout << x << " ";  // 1 2 2 3 5 6
    cout << endl;
    return 0;
}
