/*
合并两个有序数组
把有序数组 nums2 合并到 nums1，使合并后仍有序。nums1 长度为 m+n。
*/

#include <iostream>
#include <vector>

using namespace std;

class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        int i = m - 1, j = n - 1, k = m + n - 1;
        while (i >= 0 && j >= 0) {
            nums1[k--] = nums1[i] > nums2[j] ? nums1[i--] : nums2[j--];
        }
        while (j >= 0) nums1[k--] = nums2[j--];
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
